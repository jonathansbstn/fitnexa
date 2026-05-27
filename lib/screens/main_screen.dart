import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';
import '../widgets/snack_helper.dart';
import 'tab_dashboard.dart';
import 'tab_workout.dart';
import 'tab_ai.dart';
import 'tab_history.dart';
import 'tab_profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _tabs = [
    _TabItem(icon: '🏠', label: 'Home'),
    _TabItem(icon: '💪', label: 'Workout'),
    _TabItem(icon: '🤖', label: 'AI'),
    _TabItem(icon: '📋', label: 'Riwayat'),
    _TabItem(icon: '👤', label: 'Profil'),
  ];

  void navigateToTab(int index) {
    setState(() => _currentIndex = index);
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
      backgroundColor: context.appBg,
      appBar: AppBar(
        backgroundColor: context.appBg,
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
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: context.appCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.appDivider),
              ),
              child: const Center(
                child: Text('🔔', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          IconButton(
            onPressed: () => navigateToTab(4),
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: context.appCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.appDivider),
              ),
              child: const Center(
                child: Text('⚙️', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.appCard,
          border: Border(top: BorderSide(color: context.appDivider)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final selected = i == _currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _tabs[i].icon,
                          style: TextStyle(
                            fontSize: 20,
                            color: selected ? null : context.appTextMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tabs[i].label,
                          style: TextStyle(
                            fontSize: 10,
                            color: selected
                                ? AppColors.primary
                                : context.appTextMuted,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: selected ? 4 : 0,
                          height: selected ? 4 : 0,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}
