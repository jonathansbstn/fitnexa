import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/gradient_button.dart';

class TabDashboard extends StatelessWidget {
  final VoidCallback? onNavigateToWorkout;
  const TabDashboard({super.key, this.onNavigateToWorkout});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Selamat Pagi'
        : hour < 17
            ? 'Selamat Siang'
            : 'Selamat Malam';

    // Ambil weeklyData dari provider (computed dari logs asli)
    final weekly = prov.weeklyData;
    final maxCal = weekly.map((w) => w.calories).fold(0, (a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Greeting ────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C42), Color(0xFF00D4AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, 👋',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prov.userName.split(' ')[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _motivationalQuote(hour),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: onNavigateToWorkout,
                        icon: const Text('⚡', style: TextStyle(fontSize: 14)),
                        label: const Text(
                          'Mulai Workout',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      prov.userInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Streak + Stats Row ───────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  emoji: '🔥',
                  value: '${prov.streak}',
                  label: 'Hari Streak',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  emoji: '🏋️',
                  value: '${prov.logs.length}',
                  label: 'Workout',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  emoji: '⚡',
                  value: '${prov.totalCalories}',
                  label: 'Kalori',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Weekly Chart (data dari logs asli) ───────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'Aktivitas Minggu Ini',
                      style: TextStyle(
                        color: context.appTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '7 hari',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Loading state
                if (prov.isLoading)
                  const Center(
                    child: SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 104,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: weekly.asMap().entries.map((entry) {
                        final i = entry.key;
                        final d = entry.value;
                        final h = maxCal > 0
                            ? (d.calories / maxCal * 56).clamp(4.0, 56.0)
                            : 4.0;
                        // Hari ini = index 6 (paling kanan)
                        final isToday = i == 6;
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (d.calories > 0)
                                Text(
                                  '${d.calories}',
                                  style: TextStyle(
                                    color: isToday
                                        ? AppColors.primary
                                        : context.appTextMuted,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOut,
                                height: h,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 3),
                                decoration: BoxDecoration(
                                  gradient: isToday
                                      ? const LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.warning,
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        )
                                      : null,
                                  color: isToday
                                      ? null
                                      : AppColors.primary
                                          .withValues(alpha: 0.3),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                d.day,
                                style: TextStyle(
                                  color: context.appTextMuted,
                                  fontSize: 10,
                                  fontWeight: isToday
                                      ? FontWeight.w800
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Kalori terbakar per hari (kal)',
                  style: TextStyle(
                    color: context.appTextMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Today's Plan ─────────────────────────────────────────────
          AppCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'Workout Hari Ini',
                          style: TextStyle(
                            color: context.appTextPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '4 Latihan',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...[
                  ('💪', 'Push Up', '20x', AppColors.primary),
                  ('🦵', 'Squat', '30x', AppColors.accent),
                  ('🏋️', 'Plank', '1 menit', AppColors.warning),
                  ('⚡', 'Jumping Jack', '20x', AppColors.purple),
                ].asMap().entries.map(
                  (e) => _PlanRow(
                    icon: e.value.$1,
                    name: e.value.$2,
                    reps: e.value.$3,
                    color: e.value.$4,
                    isLast: e.key == 3,
                  ),
                ),
                const SizedBox(height: 14),
                GradientButton(
                  label: 'Mulai Workout ⚡',
                  onPressed: onNavigateToWorkout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Tips Card ────────────────────────────────────────────────
          AppCard(
            gradient: LinearGradient(
              colors: [
                AppColors.purple.withValues(alpha: 0.18),
                AppColors.accent.withValues(alpha: 0.08),
              ],
            ),
            border:
                Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('💡', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips Hari Ini',
                        style: TextStyle(
                          color: AppColors.purple,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _dailyTip(DateTime.now().day),
                        style: TextStyle(
                          color: context.appTextPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── SDGs Banner ──────────────────────────────────────────────
          AppCard(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00543C).withValues(alpha: 0.22),
                AppColors.accent.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(
                color: const Color(0xFF00543C).withValues(alpha: 0.45)),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00543C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🌿', style: TextStyle(fontSize: 20)),
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
                        fontSize: 11,
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
        ],
      ),
    );
  }

  String _motivationalQuote(int hour) {
    if (hour < 12) return '💪 Awali harimu dengan latihan!';
    if (hour < 17) return '🔥 Jangan biarkan semangatmu padam!';
    return '⭐ Akhiri hari dengan prestasi!';
  }

  String _dailyTip(int day) {
    const tips = [
      'Minum air putih 8 gelas sehari untuk mendukung performa workout.',
      'Istirahat yang cukup sama pentingnya dengan latihan keras.',
      'Pemanasan 5 menit sebelum workout mencegah cedera.',
      'Konsistensi lebih penting dari intensitas di awal.',
      'Tambah 1-2 repetisi setiap minggu untuk progres optimal.',
      'Protein setelah workout membantu pemulihan otot.',
      'Stretching setelah latihan mengurangi nyeri otot.',
    ];
    return tips[day % tips.length];
  }
}

// ── Stat Card ──────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String emoji, value, label;
  final Color color;
  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
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

// ── Plan Row ───────────────────────────────────────────────────────────────
class _PlanRow extends StatelessWidget {
  final String icon, name, reps;
  final Color color;
  final bool isLast;
  const _PlanRow({
    required this.icon,
    required this.name,
    required this.reps,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: context.appTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      reps,
                      style: TextStyle(
                        color: context.appTextMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '✓',
                    style:
                        TextStyle(color: context.appTextMuted, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: context.appDivider, height: 1),
      ],
    );
  }
}
