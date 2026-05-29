import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';
import '../providers/app_provider.dart';
import '../models/workout_log.dart';
import '../services/sound_service.dart';
import '../widgets/snack_helper.dart';
import 'workout_log_modal.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutLog log;
  const WorkoutDetailScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final heroTag = 'workout-${log.firestoreId ?? log.id}';

    return Scaffold(
      backgroundColor: context.appBg,
      appBar: AppBar(
        backgroundColor: context.appBg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            SoundService.instance.playTap();
            Navigator.of(context).pop();
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.appDivider),
            ),
            child: Icon(Icons.arrow_back_ios_new,
                color: context.appTextPrimary, size: 16),
          ),
        ),
        title: Text(
          'Detail Workout',
          style: TextStyle(
            color: context.appTextPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          // Edit button di AppBar
          GestureDetector(
            onTap: () {
              SoundService.instance.playTap();
              showWorkoutLogModal(context, editing: log);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4)),
              ),
              child: const Text(
                '✏ Edit',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Icon + Nama ─────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Hero(
                    tag: heroTag,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.25),
                            AppColors.accent.withValues(alpha: 0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          log.icon,
                          style: const TextStyle(fontSize: 44),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    log.exercise,
                    style: TextStyle(
                      color: context.appTextPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (log.category.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        log.category,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Stats Grid ──────────────────────────────────────────────
            Text(
              'Statistik Workout',
              style: TextStyle(
                color: context.appTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _StatTile(
                  icon: '📅',
                  label: 'Tanggal',
                  value: log.date,
                  color: AppColors.primary,
                ),
                _StatTile(
                  icon: '🔁',
                  label: 'Repetisi',
                  value: '${log.reps}x',
                  color: AppColors.accent,
                ),
                _StatTile(
                  icon: '⏱',
                  label: 'Durasi',
                  value: '${log.duration} detik',
                  color: AppColors.warning,
                ),
                _StatTile(
                  icon: '🔥',
                  label: 'Kalori',
                  value: '${log.calories} kal',
                  color: AppColors.danger,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Action Buttons ───────────────────────────────────────────
            Row(
              children: [
                // Edit
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        showWorkoutLogModal(context, editing: log),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '✏  Edit Workout',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Delete
                Expanded(
                  child: GestureDetector(
                    onTap: () => _confirmDelete(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '🗑  Hapus',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.appCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Workout?',
          style: TextStyle(
            color: ctx.appTextPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Data "${log.exercise}" akan dihapus permanen dari riwayat.',
          style: TextStyle(color: ctx.appTextMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: TextStyle(color: ctx.appTextMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                  color: AppColors.danger, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    SoundService.instance.playDelete();
    HapticFeedback.heavyImpact();
    await context.read<AppProvider>().deleteLog(log);
    if (!context.mounted) return;

    showSnack(context, '${log.exercise} berhasil dihapus! 🗑', isError: true);
    Navigator.of(context).pop();
  }
}

// ── Stat Tile ─────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String icon, label, value;
  final Color color;
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: context.appTextMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
