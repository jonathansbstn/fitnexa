import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';
import '../providers/app_provider.dart';
import '../models/exercise_model.dart';
import '../services/sound_service.dart';
import '../widgets/snack_helper.dart';
import 'workout_log_modal.dart';

class TabWorkout extends StatefulWidget {
  const TabWorkout({super.key});
  @override
  State<TabWorkout> createState() => _TabWorkoutState();
}

class _TabWorkoutState extends State<TabWorkout>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _hasPlayedConfetti = false;

  // Filter kategori exercise
  String _selectedCategory = 'Semua';

  List<String> get _categories {
    final cats = Exercise.all.map((e) => e.category).toSet().toList()..sort();
    return ['Semua', ...cats];
  }

  List<Exercise> get _filteredExercises {
    if (_selectedCategory == 'Semua') return Exercise.all;
    return Exercise.all
        .where((e) => e.category == _selectedCategory)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _triggerConfetti() {
    if (_hasPlayedConfetti) return;
    _hasPlayedConfetti = true;
    HapticFeedback.heavyImpact();
    SoundService.instance.playFinish();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _confettiCtrl.play();
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        context.read<AppProvider>().resetWorkoutFinished();
        setState(() => _hasPlayedConfetti = false);
      });
    });
  }

  // ── Konfirmasi selesai workout (feature #6) ───────────────────────────
  void _showFinishConfirmation(BuildContext context, AppProvider prov) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: context.appCard,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: context.appDivider),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: context.appCardLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const Text('🎯', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Selesaikan Workout?',
              style: TextStyle(
                color: context.appTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${prov.activeWorkout?.name ?? ''} · ${prov.timerFormatted} berlalu',
              style: TextStyle(
                color: context.appTextMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Workout akan dicatat info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Text(
                    prov.activeWorkout?.icon ?? '🏋️',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prov.activeWorkout?.name ?? '',
                          style: TextStyle(
                            color: context.appTextPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '⏱ ${prov.timerFormatted}  ·  🔥 ${prov.activeWorkout?.calories ?? 0} kal',
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
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                // Lanjut latihan
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      SoundService.instance.playTap();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: context.appCardLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.appDivider),
                      ),
                      child: Center(
                        child: Text(
                          '▶  Lanjut',
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
                // Selesai
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      prov.finishWorkout();
                      HapticFeedback.heavyImpact();
                      // playFinish called from _triggerConfetti
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '✓  Selesaikan!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final exercises = _filteredExercises;

    if (prov.workoutJustFinished) {
      _triggerConfetti();
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latihan',
                        style: TextStyle(
                          color: context.appTextPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${exercises.length} gerakan tersedia',
                        style: TextStyle(
                          color: context.appTextMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      showWorkoutLogModal(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        '+ Log',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Workout Selesai Card ──────────────────────────────────
              if (prov.workoutJustFinished) ...[
                _WorkoutDoneCard(
                  onDismiss: () {
                    prov.resetWorkoutFinished();
                    setState(() => _hasPlayedConfetti = false);
                  },
                ),
                const SizedBox(height: 16),
              ],

              // ── Active Timer Card ─────────────────────────────────────
              if (prov.activeWorkout != null &&
                  !prov.workoutJustFinished) ...[
                _ActiveTimerCard(
                  prov: prov,
                  pulseAnim: _pulseAnim,
                  onFinishTap: () =>
                      _showFinishConfirmation(context, prov),
                ),
                const SizedBox(height: 16),
              ],

              // ── Filter Kategori ───────────────────────────────────────
              Text(
                'Pilih Gerakan',
                style: TextStyle(
                  color: context.appTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isActive = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = cat);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── Exercise Grid ─────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: GridView.builder(
                  key: ValueKey(_selectedCategory),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exercises.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  itemBuilder: (ctx, i) {
                    final ex = exercises[i];
                    final isActive = prov.activeWorkout?.id == ex.id;
                    return GestureDetector(
                      onTap: () {
                          HapticFeedback.lightImpact();
                          SoundService.instance.playStart();
                          prov.startWorkout(ex);
                          showSnack(
                              context, '${ex.icon} Mulai ${ex.name}!');
                        },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : context.appCard,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : context.appDivider,
                            width: isActive ? 2 : 1,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(ex.icon,
                                    style:
                                        const TextStyle(fontSize: 30)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    ex.category,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ex.name,
                              style: TextStyle(
                                color: context.appTextPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('⏱ ${ex.duration}',
                                    style: TextStyle(
                                        color: context.appTextMuted,
                                        fontSize: 11)),
                                const SizedBox(width: 8),
                                Text('🔁 ${ex.reps}',
                                    style: TextStyle(
                                        color: context.appTextMuted,
                                        fontSize: 11)),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '🔥 ${ex.calories} kal',
                                  style: const TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.primary
                                            .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '▶',
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.white
                                            : AppColors.primary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ── Confetti ─────────────────────────────────────────────────
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiCtrl,
            blastDirection: pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 40,
            gravity: 0.25,
            emissionFrequency: 0.06,
            maxBlastForce: 30,
            minBlastForce: 8,
            colors: const [
              AppColors.primary,
              AppColors.accent,
              AppColors.warning,
              Colors.white,
              Color(0xFFFF6B35),
              Color(0xFFFF4757),
              Color(0xFF2ED573),
            ],
            shouldLoop: false,
          ),
        ),
      ],
    );
  }
}

// ── Active Timer Card ─────────────────────────────────────────────────────
class _ActiveTimerCard extends StatelessWidget {
  final AppProvider prov;
  final Animation<double> pulseAnim;
  final VoidCallback onFinishTap;

  const _ActiveTimerCard({
    required this.prov,
    required this.pulseAnim,
    required this.onFinishTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(prov.activeWorkout!.icon,
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                prov.activeWorkout!.name,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: prov.timerRunning
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              prov.timerRunning ? '🔴  SEDANG BERJALAN' : '⏸  DIJEDA',
              style: TextStyle(
                color: prov.timerRunning
                    ? AppColors.primary
                    : AppColors.warning,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 10,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: prov.targetSeconds > 0 ? prov.timerProgress : null,
                  strokeWidth: 10,
                  backgroundColor: Colors.transparent,
                  color: AppColors.primary,
                  strokeCap: StrokeCap.round,
                ),
              ),
              ScaleTransition(
                scale: prov.timerRunning
                    ? pulseAnim
                    : const AlwaysStoppedAnimation(1.0),
                child: Column(
                  children: [
                    Text(
                      prov.timerFormatted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (prov.targetSeconds > 0)
                      Text(
                        'dari ${prov.targetSeconds}s',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (prov.timerRunning) {
                      SoundService.instance.playPause();
                    } else {
                      SoundService.instance.playResume();
                    }
                    prov.pauseResumeTimer();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: prov.timerRunning
                          ? AppColors.warning.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: prov.timerRunning
                            ? AppColors.warning.withValues(alpha: 0.5)
                            : AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        prov.timerRunning ? '⏸  Pause' : '▶  Lanjut',
                        style: TextStyle(
                          color: prov.timerRunning
                              ? AppColors.warning
                              : AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onFinishTap, // ← konfirmasi dulu
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '✓  Selesai',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Workout Done Card ─────────────────────────────────────────────────────
class _WorkoutDoneCard extends StatelessWidget {
  final VoidCallback onDismiss;
  const _WorkoutDoneCard({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AppProvider>();
    final latestLog = prov.logs.isNotEmpty ? prov.logs.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4AA), Color(0xFF00A88A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text(
            'Workout Selesai!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            latestLog != null ? latestLog.exercise : 'Kerja bagus!',
            style:
                const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          if (latestLog != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _DoneStat('⏱', '${latestLog.duration}s', 'Durasi'),
                _DoneStat(
                    '🔥', '${latestLog.calories}', 'Kalori'),
                _DoneStat('🔁', '${latestLog.reps}x', 'Reps'),
              ],
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Share / Copy
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    final msg = latestLog != null
                        ? '💪 Baru selesai ${latestLog.exercise}!\n'
                            '⏱ ${latestLog.duration}s | '
                            '🔥 ${latestLog.calories} kal | '
                            '🔁 ${latestLog.reps}x reps\n'
                            'Tracked with FITNEXA 🚀'
                        : '💪 Workout selesai! Tracked with FITNEXA 🚀';
                    await Clipboard.setData(ClipboardData(text: msg));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('📋 Disalin ke clipboard!'),
                        backgroundColor: const Color(0xFF1A1A2E),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: const Center(
                      child: Text(
                        '📤 Bagikan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Lanjut
              Expanded(
                child: GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: const Center(
                      child: Text(
                        'Lanjut',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoneStat extends StatelessWidget {
  final String emoji, value, label;
  const _DoneStat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
