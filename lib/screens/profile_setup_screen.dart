import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';
import '../providers/app_provider.dart';
import '../models/user_profile.dart';
import '../services/sound_service.dart';
import '../widgets/snack_helper.dart';
import 'main_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isEditing;
  const ProfileSetupScreen({super.key, this.isEditing = false});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _currentStep = 0;

  // Step 1: Gender
  String _gender = 'pria';

  // Step 2: Body Info
  double _weight = 60;
  double _height = 165;

  // Step 3: Goal
  String _goal = 'general';

  // Gradient colors per step
  static const _stepGradients = [
    [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
    [Color(0xFFFF6B35), Color(0xFFFF4757)],
    [Color(0xFF2ED573), Color(0xFF00D4AA)],
  ];

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    // Pre-fill data if editing
    if (widget.isEditing) {
      final prov = context.read<AppProvider>();
      final profile = prov.userProfile;
      if (profile != null) {
        _gender = profile.gender;
        _weight = profile.weight;
        _height = profile.height;
        _goal = profile.fitnessGoal;
      }
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < 2) {
      HapticFeedback.selectionClick();
      SoundService.instance.playNavigate();
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    HapticFeedback.selectionClick();
    SoundService.instance.playTap();
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _finish() async {
    final profile = UserProfile(
      gender: _gender,
      weight: _weight,
      height: _height,
      fitnessGoal: _goal,
    );

    await context.read<AppProvider>().saveUserProfile(profile);

    if (!mounted) return;
    SoundService.instance.playLoginSuccess();
    HapticFeedback.heavyImpact();
    showSnack(context, 'Profil berhasil disimpan! 🎉');

    if (widget.isEditing) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  double get _bmi => _weight / ((_height / 100) * (_height / 100));

  Color get _bmiColor {
    if (_bmi < 18.5) return AppColors.warning;
    if (_bmi < 25) return AppColors.success;
    if (_bmi < 30) return AppColors.warning;
    return AppColors.danger;
  }

  String get _bmiLabel {
    if (_bmi < 18.5) return 'Underweight';
    if (_bmi < 25) return 'Normal';
    if (_bmi < 30) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    final colors = _stepGradients[_currentStep];
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors[0].withValues(alpha: 0.25),
              colors[1].withValues(alpha: 0.08),
              context.appBg,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                // ── Header + Progress ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      // Skip (only if not editing and not last step)
                      if (!widget.isEditing)
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: _finish,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                'Lewati',
                                style: TextStyle(
                                  color: context.appTextMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Progress bar
                      Row(
                        children: List.generate(3, (i) {
                          final isActive = i <= _currentStep;
                          return Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 4,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: isActive
                                    ? LinearGradient(
                                        colors: [colors[0], colors[1]])
                                    : null,
                                color: isActive ? null : context.appCardLight,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Langkah ${_currentStep + 1} dari 3',
                        style: TextStyle(
                          color: context.appTextMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── PageView ──────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) =>
                        setState(() => _currentStep = i),
                    children: [
                      _buildGenderStep(),
                      _buildBodyStep(),
                      _buildGoalStep(),
                    ],
                  ),
                ),

                // ── Bottom Buttons ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Row(
                    children: [
                      if (_currentStep > 0) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: _back,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: context.appCard,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: context.appDivider),
                              ),
                              child: Center(
                                child: Text(
                                  '← Kembali',
                                  style: TextStyle(
                                    color: context.appTextPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: _currentStep > 0 ? 2 : 1,
                        child: GestureDetector(
                          onTap: _next,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [colors[0], colors[1]],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: colors[0].withValues(alpha: 0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _currentStep == 2
                                    ? '✓  Selesai!'
                                    : 'Selanjutnya →',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Step 1: Gender
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildGenderStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Text('👤', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            'Pilih Gender',
            style: TextStyle(
              color: context.appTextPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bantu kami personalisasi program latihan',
            style: TextStyle(color: context.appTextMuted, fontSize: 14),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              _genderCard('pria', '🧑', 'Pria'),
              const SizedBox(width: 16),
              _genderCard('wanita', '👩', 'Wanita'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _genderCard(String value, String emoji, String label) {
    final selected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          SoundService.instance.playTap();
          setState(() => _gender = value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : context.appCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : context.appDivider,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              AnimatedScale(
                scale: selected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Text(emoji, style: const TextStyle(fontSize: 56)),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppColors.primary
                      : context.appTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (selected) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '✓ Dipilih',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Step 2: Body Info
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBodyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Text('📏', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            'Info Tubuhmu',
            style: TextStyle(
              color: context.appTextPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Data ini membantu menghitung kalori',
            style: TextStyle(color: context.appTextMuted, fontSize: 14),
          ),
          const SizedBox(height: 32),

          // Weight
          _bodyInfoCard(
            emoji: '⚖️',
            label: 'Berat Badan',
            value: '${_weight.toStringAsFixed(0)} kg',
            slider: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: context.appCardLight,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.2),
                trackHeight: 6,
              ),
              child: Slider(
                min: 30,
                max: 150,
                divisions: 120,
                value: _weight,
                onChanged: (v) => setState(() => _weight = v),
              ),
            ),
            rangeLabel: '30 kg — 150 kg',
          ),
          const SizedBox(height: 16),

          // Height
          _bodyInfoCard(
            emoji: '📐',
            label: 'Tinggi Badan',
            value: '${_height.toStringAsFixed(0)} cm',
            slider: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: context.appCardLight,
                thumbColor: AppColors.accent,
                overlayColor: AppColors.accent.withValues(alpha: 0.2),
                trackHeight: 6,
              ),
              child: Slider(
                min: 100,
                max: 220,
                divisions: 120,
                value: _height,
                onChanged: (v) => setState(() => _height = v),
              ),
            ),
            rangeLabel: '100 cm — 220 cm',
          ),
          const SizedBox(height: 20),

          // BMI indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bmiColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bmiColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _bmiColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _bmi < 18.5
                          ? '⚠️'
                          : _bmi < 25
                              ? '✅'
                              : _bmi < 30
                                  ? '⚠️'
                                  : '🔴',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BMI: ${_bmi.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: _bmiColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        _bmiLabel,
                        style: TextStyle(
                          color: context.appTextMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyInfoCard({
    required String emoji,
    required String label,
    required String value,
    required Widget slider,
    required String rangeLabel,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appDivider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: context.appTextMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                value,
                style: TextStyle(
                  color: context.appTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          slider,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rangeLabel.split('—')[0].trim(),
                  style: TextStyle(
                      color: context.appTextMuted, fontSize: 10)),
              Text(rangeLabel.split('—')[1].trim(),
                  style: TextStyle(
                      color: context.appTextMuted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Step 3: Fitness Goal
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildGoalStep() {
    const goals = [
      ('fat_loss', '🔥', 'Fat Loss', 'Bakar lemak & turunkan berat'),
      ('muscle_gain', '💪', 'Muscle Gain', 'Bangun massa otot'),
      ('endurance', '🏃', 'Endurance', 'Tingkatkan stamina & daya tahan'),
      ('general', '⭐', 'General', 'Fitness umum & kebugaran'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Text('🎯', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            'Target Olahragamu',
            style: TextStyle(
              color: context.appTextPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih tujuan utama latihan',
            style: TextStyle(color: context.appTextMuted, fontSize: 14),
          ),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.95,
            children: goals.map((g) {
              final selected = _goal == g.$1;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  SoundService.instance.playTap();
                  setState(() => _goal = g.$1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : context.appCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.accent
                          : context.appDivider,
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.accent.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: selected ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(g.$2,
                            style: const TextStyle(fontSize: 36)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        g.$3,
                        style: TextStyle(
                          color: selected
                              ? AppColors.accent
                              : context.appTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        g.$4,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.appTextMuted,
                          fontSize: 10,
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '✓',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
