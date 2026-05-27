import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/snack_helper.dart';
import 'auth_screen.dart';

class TabProfile extends StatelessWidget {
  const TabProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          // ── Avatar + name ────────────────────────────────────────────
          Container(
            width: 88,
            height: 88,
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
          const SizedBox(height: 14),
          Text(
            prov.userName,
            style: TextStyle(
              color: context.appTextPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
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
                  label: 'Kalori',
                  value: '${prov.totalCalories}',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileStat(
                  label: 'Streak',
                  value: '${prov.streak}',
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
                  children: [
                    ('🔥', '7 Hari Streak', true),
                    ('💪', '10 Workout', true),
                    ('⚡', '50 Kalori', true),
                    ('🏃', '30 Hari Streak', false),
                  ].map((a) {
                    final unlocked = a.$3;
                    return Opacity(
                      opacity: unlocked ? 1.0 : 0.35,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: unlocked
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : context.appCardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: unlocked
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              a.$1,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                a.$2,
                                style: TextStyle(
                                  color: unlocked
                                      ? context.appTextPrimary
                                      : context.appTextMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
            border:
                Border.all(color: const Color(0xFF00543C).withValues(alpha: 0.5)),
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
                    icon: '⚙️',
                    label: 'Pengaturan',
                    onTap: () =>
                        showSnack(context, '⚙️ Pengaturan akan segera hadir!'),
                    trailing: Icon(Icons.chevron_right,
                        color: context.appTextMuted, size: 20),
                  ),
                  (
                    icon: '🔔',
                    label: 'Notifikasi',
                    onTap: () => showSnack(context, '🔔 Notifikasi aktif'),
                    trailing: Icon(Icons.chevron_right,
                        color: context.appTextMuted, size: 20),
                  ),
                  (
                    icon: '🌙',
                    label: 'Dark Mode',
                    onTap: () => prov.toggleDarkMode(),
                    trailing: Switch(
                      value: prov.isDarkMode,
                      onChanged: (_) => prov.toggleDarkMode(),
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                        onTap: item.onTap,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Text(
                                item.icon,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: context.appTextPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              item.trailing,
                            ],
                          ),
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          color: context.appDivider,
                          height: 1,
                        ),
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
  const _ProfileStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: context.appTextMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
