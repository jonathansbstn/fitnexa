import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';
import '../providers/app_provider.dart';
import '../services/sound_service.dart';
import '../widgets/app_card.dart';
import '../widgets/streak_calendar.dart';
import '../widgets/snack_helper.dart';
import 'auth_screen.dart';

class TabProfile extends StatelessWidget {
  const TabProfile({super.key});

  void _editName(BuildContext context, AppProvider prov) {
    final ctrl = TextEditingController(text: prov.userName);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.appCard,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: context.appDivider),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: context.appCardLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('✏ Edit Nama',
                  style: TextStyle(
                    color: context.appTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: context.appCardLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.appDivider),
                ),
                child: TextField(
                  controller: ctrl,
                  autofocus: true,
                  style: TextStyle(
                      color: context.appTextPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Nama kamu',
                    hintStyle:
                        TextStyle(color: context.appTextMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final name = ctrl.text.trim();
                  if (name.isEmpty) return;
                  await context.read<AppProvider>().updateUserName(name);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  showSnack(context, '✅ Nama diperbarui!');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Simpan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editTarget(BuildContext context, AppProvider prov) {
    int target = prov.targetCalories;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Container(
          decoration: BoxDecoration(
            color: context.appCard,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: context.appDivider),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: context.appCardLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('🎯 Target Kalori Harian',
                  style: TextStyle(
                    color: context.appTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: 24),
              Text(
                '$target kal',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: target.toDouble(),
                min: 100,
                max: 2000,
                divisions: 38,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withValues(alpha: 0.2),
                onChanged: (v) => setSt(() => target = v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('100 kal',
                      style: TextStyle(
                          color: context.appTextMuted, fontSize: 11)),
                  Text('2000 kal',
                      style: TextStyle(
                          color: context.appTextMuted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  await context.read<AppProvider>().setTargetCalories(target);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  showSnack(context, '✅ Target $target kal disimpan!');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Simpan Target',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final calorieProgress =
        (prov.todayCalories / prov.targetCalories).clamp(0.0, 1.0);

    // Workout dates set untuk streak calendar
    final workoutDates = prov.logs.map((l) => l.date).toSet();

    // Dynamic achievements
    final achievements = [
      (
        icon: '🔥',
        label: '3 Hari Streak',
        unlocked: prov.streak >= 3,
      ),
      (
        icon: '💪',
        label: '10 Workout',
        unlocked: prov.logs.length >= 10,
      ),
      (
        icon: '⚡',
        label: '500 Kalori',
        unlocked: prov.totalCalories >= 500,
      ),
      (
        icon: '🏆',
        label: '30 Hari Streak',
        unlocked: prov.streak >= 30,
      ),
      (
        icon: '🌟',
        label: '50 Workout',
        unlocked: prov.logs.length >= 50,
      ),
      (
        icon: '🚀',
        label: '5000 Kalori',
        unlocked: prov.totalCalories >= 5000,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          // ── Avatar + Edit name ────────────────────────────────────────
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _editName(context, prov);
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.38),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      prov.userInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.appBg, width: 2),
                  ),
                  child: const Center(
                    child: Text('✏', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _editName(context, prov),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  prov.userName,
                  style: TextStyle(
                    color: context.appTextPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.edit, color: context.appTextMuted, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            prov.userEmail,
            style: TextStyle(color: context.appTextMuted, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  '${prov.streak} Hari Streak',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Stats ────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ProfileStat(
                  label: 'Workout',
                  value: '${prov.logs.length}',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileStat(
                  label: 'Kalori Total',
                  value: '${prov.totalCalories}',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileStat(
                  label: 'Streak',
                  value: '${prov.streak}d',
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Kalori Hari Ini vs Target ──────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🔥 Kalori Hari Ini',
                      style: TextStyle(
                        color: context.appTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _editTarget(context, prov),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Target: ${prov.targetCalories} kal ✏',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Progress ring
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 1,
                            strokeWidth: 8,
                            color: context.appCardLight,
                          ),
                          CircularProgressIndicator(
                            value: calorieProgress,
                            strokeWidth: 8,
                            backgroundColor: Colors.transparent,
                            color: calorieProgress >= 1
                                ? AppColors.accent
                                : AppColors.warning,
                            strokeCap: StrokeCap.round,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(calorieProgress * 100).round()}%',
                                style: TextStyle(
                                  color: context.appTextPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${prov.todayCalories} kal',
                            style: const TextStyle(
                              color: AppColors.warning,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'dari ${prov.targetCalories} kal target',
                            style: TextStyle(
                              color: context.appTextMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: calorieProgress,
                              minHeight: 6,
                              backgroundColor:
                                  context.appCardLight,
                              color: calorieProgress >= 1
                                  ? AppColors.accent
                                  : AppColors.warning,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            calorieProgress >= 1
                                ? '🎉 Target tercapai!'
                                : '${prov.targetCalories - prov.todayCalories} kal lagi',
                            style: TextStyle(
                              color: calorieProgress >= 1
                                  ? AppColors.accent
                                  : context.appTextMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Streak Calendar ────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📅 Kalender Workout',
                  style: TextStyle(
                    color: context.appTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                StreakCalendar(workoutDates: workoutDates),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Achievements ─────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🏆 Pencapaian',
                  style: TextStyle(
                    color: context.appTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3.2,
                  children: achievements.map((a) {
                    return Opacity(
                      opacity: a.unlocked ? 1.0 : 0.35,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: a.unlocked
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : context.appCardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: a.unlocked
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(a.icon,
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                a.label,
                                style: TextStyle(
                                  color: a.unlocked
                                      ? context.appTextPrimary
                                      : context.appTextMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (a.unlocked)
                              const Text('✅',
                                  style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── SDGs ─────────────────────────────────────────────────────
          AppCard(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00543C).withValues(alpha: 0.25),
                AppColors.accent.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(
                color: const Color(0xFF00543C).withValues(alpha: 0.5)),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00543C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🌿', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SDGs Goal #3',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Good Health & Well-being',
                      style: TextStyle(
                        color: context.appTextPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Aktif setiap hari untuk hidup sehat',
                      style: TextStyle(
                        color: context.appTextMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Menu ─────────────────────────────────────────────────────
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: (() {
                final items = [
                  (
                    icon: '🎯',
                    label: 'Target Kalori',
                    onTap: () => _editTarget(context, prov),
                    trailing: Text(
                      '${prov.targetCalories} kal',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ),
                  (
                    icon: '🌙',
                    label: 'Dark Mode',
                    onTap: () => prov.toggleDarkMode(),
                    trailing: Switch(
                      value: prov.isDarkMode,
                      onChanged: (_) => prov.toggleDarkMode(),
                      activeThumbColor: AppColors.primary,
                      activeTrackColor:
                          AppColors.primary.withValues(alpha: 0.3),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  (
                    icon: 'ℹ️',
                    label: 'Tentang FITNEXA',
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'FITNEXA',
                      applicationVersion: '1.0.0',
                      applicationLegalese:
                          '© 2026 FITNEXA. AI-Powered Workout Tracker.\nMendukung SDGs Goal #3 – Good Health & Well-being.',
                    ),
                    trailing: Icon(Icons.chevron_right,
                        color: context.appTextMuted, size: 20),
                  ),
                ];
                return items.asMap().entries.map((e) {
                  final isLast = e.key == items.length - 1;
                  final item = e.value;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          SoundService.instance.playToggle();
                          item.onTap();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Text(item.icon,
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 12),
                              Text(item.label,
                                  style: TextStyle(
                                      color: context.appTextPrimary,
                                      fontSize: 14)),
                              const Spacer(),
                              item.trailing,
                            ],
                          ),
                        ),
                      ),
                      if (!isLast)
                        Divider(color: context.appDivider, height: 1),
                    ],
                  );
                }).toList();
              })(),
            ),
          ),
          const SizedBox(height: 14),

          // ── Logout ───────────────────────────────────────────────────
          GestureDetector(
            onTap: () async {
              HapticFeedback.mediumImpact();
              SoundService.instance.playLogout();
              await context.read<AppProvider>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AuthScreen(),
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 400),
                ),
                (_) => false,
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.35)),
              ),
              child: const Center(
                child: Text(
                  'Keluar',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ProfileStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: context.appTextMuted, fontSize: 11)),
        ],
      ),
    );
  }
}
