import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';
import '../providers/app_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/snack_helper.dart';

class TabAI extends StatelessWidget {
  final VoidCallback? onNavigateToWorkout;
  const TabAI({super.key, this.onNavigateToWorkout});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Workout',
                      style: TextStyle(
                        color: context.appTextPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Rekomendasi cerdas berbasis kondisimu',
                      style: TextStyle(
                        color: context.appTextMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.purple.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🤖', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Text(
                      'Rule-Based AI',
                      style: TextStyle(
                        color: AppColors.purple,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── AI Config Card ───────────────────────────────────────────
          AppCard(
            gradient: LinearGradient(
              colors: [
                AppColors.purple.withValues(alpha: 0.18),
                AppColors.accent.withValues(alpha: 0.06),
              ],
            ),
            border:
                Border.all(color: AppColors.purple.withValues(alpha: 0.35)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title
                Row(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'Pilih Preferensimu',
                      style: TextStyle(
                        color: context.appTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Goal selector
                Text(
                  'Tujuan Workout',
                  style: TextStyle(
                    color: context.appTextMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3.2,
                  children: [
                    ('fat_loss', '🔥 Fat Loss'),
                    ('muscle_gain', '💪 Muscle Gain'),
                    ('endurance', '🏃 Endurance'),
                    ('general', '⭐ General'),
                  ].map((g) {
                    final selected = prov.aiGoal == g.$1;
                    return GestureDetector(
                      onTap: () => prov.setAiGoal(g.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : context.appCardLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            g.$2,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : context.appTextMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Level selector
                Text(
                  'Level Latihan',
                  style: TextStyle(
                    color: context.appTextMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ('beginner', '🌱 Pemula'),
                    ('intermediate', '⚡ Menengah'),
                    ('advanced', '🔥 Mahir'),
                  ].map((lv) {
                    final selected = prov.aiLevel == lv.$1;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => prov.setAiLevel(lv.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accent
                                : context.appCardLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              lv.$2,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.bg
                                    : context.appTextMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Duration slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Durasi Workout',
                      style: TextStyle(
                        color: context.appTextMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${prov.aiDuration} menit',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: context.appCardLight,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    min: 5,
                    max: 60,
                    divisions: 11,
                    value: prov.aiDuration.toDouble(),
                    onChanged: (v) => prov.setAiDuration(v.round()),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '5 min',
                      style: TextStyle(
                        color: context.appTextMuted,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '60 min',
                      style: TextStyle(
                        color: context.appTextMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                GradientButton(
                  label: '🤖  Dapatkan Rekomendasi AI',
                  colors: const [AppColors.purple, Color(0xFF9B72CF)],
                  onPressed: () {
                    prov.generateAI();
                    showSnack(context, 'Rekomendasi AI berhasil dihasilkan! ✨');
                  },
                ),
              ],
            ),
          ),

          // ── Results ──────────────────────────────────────────────────
          if (prov.aiRecs.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Hasil Rekomendasi',
                  style: TextStyle(
                    color: context.appTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${prov.aiRecs.length} latihan',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Info banner: tap Mulai to go to workout tab
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(
                    'Tekan "Mulai" untuk langsung ke tab Workout',
                    style: TextStyle(
                      color: context.appTextPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ...prov.aiRecs.asMap().entries.map((entry) {
              final rec = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.appCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.appDivider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          rec.exercise.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.exercise.name,
                            style: TextStyle(
                              color: context.appTextPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '💡 ${rec.reason}',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '🔁 ${rec.exercise.reps}',
                                style: TextStyle(
                                  color: context.appTextMuted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '🔥 ${rec.exercise.calories} kal',
                                style: const TextStyle(
                                  color: AppColors.warning,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Start the workout in the provider
                        context
                            .read<AppProvider>()
                            .startWorkout(rec.exercise);
                        showSnack(context, 'Memulai ${rec.exercise.name}! 💪');
                        // Navigate to the Workout tab so the timer is visible
                        if (onNavigateToWorkout != null) {
                          onNavigateToWorkout!();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Mulai ▶',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
