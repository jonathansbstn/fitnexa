import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';
import '../widgets/snack_helper.dart';
import 'tab_dashboard.dart';
import 'tab_workout.dart';
import 'tab_ai.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import 'tab_history.dart';
import 'tab_profile.dart';
import '../widgets/animated_background.dart';
import '../providers/app_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  // Animasi fade saat ganti tab
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late ConfettiController _confettiController;

  static const _tabs = [
    _TabItem(icon: '🏠', label: 'Home'),
    _TabItem(icon: '💪', label: 'Workout'),
    _TabItem(icon: '🤖', label: 'AI'),
    _TabItem(icon: '📋', label: 'Riwayat'),
    _TabItem(icon: '👤', label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void navigateToTab(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    SoundService.instance.playNavigate();
    _fadeCtrl.reset();
    setState(() => _currentIndex = index);
    _fadeCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TabDashboard(onNavigateToWorkout: () => navigateToTab(1)),
      const TabWorkout(),
      TabAI(onNavigateToWorkout: () => navigateToTab(1)),
      const TabHistory(),
      const TabProfile(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'FITNEXA',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSnack(context, '🔔 Belum ada notifikasi baru');
            },
            icon: _NavActionBtn(emoji: '🔔'),
          ),
          IconButton(
            onPressed: () => navigateToTab(4),
            icon: _NavActionBtn(emoji: '⚙️'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Body dengan FadeTransition + ScaleTransition saat ganti tab
      body: Stack(
        children: [
          AnimatedBackground(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1.0).animate(_fadeAnim),
                child: IndexedStack(
                  index: _currentIndex,
                  children: screens,
                ),
              ),
            ),
          ),
          Consumer<AppProvider>(
            builder: (context, prov, _) {
              if (prov.showConfetti) {
                _confettiController.play();
              }
              return Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // Floating Glass Bottom Nav Bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: dart_ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: context.appCard.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _BottomNav(
                currentIndex: _currentIndex,
                tabs: _tabs,
                onTap: navigateToTab,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom Nav Bar ────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_TabItem> tabs;
  final ValueChanged<int> onTap;
  const _BottomNav({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border(top: BorderSide(color: context.appDivider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final selected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon dengan scale animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: selected ? 0.8 : 1.0,
                            end: selected ? 1.15 : 1.0,
                          ),
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.elasticOut,
                          builder: (_, scale, child) => Transform.scale(
                            scale: scale,
                            child: child,
                          ),
                          child: Text(
                            tabs[i].icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            color: selected
                                ? AppColors.primary
                                : context.appTextMuted,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                          child: Text(tabs[i].label),
                        ),
                        const SizedBox(height: 3),
                        // Sliding dot indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          width: selected ? 20 : 0,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Helper widget ─────────────────────────────────────────────────────────
class _NavActionBtn extends StatelessWidget {
  final String emoji;
  const _NavActionBtn({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.appDivider),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _TabItem {
  final String icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}
