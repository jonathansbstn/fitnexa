import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';
import '../providers/app_provider.dart';
import '../models/workout_log.dart';
import '../services/sound_service.dart';
import '../widgets/app_card.dart';
import '../widgets/snack_helper.dart';
import 'workout_log_modal.dart';
import 'workout_detail_screen.dart';

class TabHistory extends StatefulWidget {
  const TabHistory({super.key});
  @override
  State<TabHistory> createState() => _TabHistoryState();
}

class _TabHistoryState extends State<TabHistory> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _filter = 'Semua';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<WorkoutLog> _filtered(List<WorkoutLog> logs) {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartStr =
        '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';

    return logs.where((log) {
      bool dateOk = true;
      if (_filter == 'Hari Ini') dateOk = log.date == todayStr;
      if (_filter == 'Minggu Ini') dateOk = log.date.compareTo(weekStartStr) >= 0;
      bool searchOk = _searchQuery.isEmpty ||
          log.exercise.toLowerCase().contains(_searchQuery.toLowerCase());
      return dateOk && searchOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final allLogs = prov.logs;
    final logs = _filtered(allLogs);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
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
                        'Riwayat',
                        style: TextStyle(
                          color: context.appTextPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${allLogs.length} aktivitas tersimpan',
                        style: TextStyle(
                          color: context.appTextMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Mini Stats ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'Total Workout',
                      value: '${allLogs.length}',
                      icon: '🏋️',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStat(
                      label: 'Total Kalori',
                      value: '${prov.totalCalories} kal',
                      icon: '🔥',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'Total Waktu',
                      value: '${prov.totalDuration}s',
                      icon: '⏱',
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStat(
                      label: 'Streak',
                      value: '${prov.streak} hari',
                      icon: '🔥',
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Search Bar ───────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: context.appCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.appDivider),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style:
                      TextStyle(color: context.appTextPrimary, fontSize: 14),
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Cari workout...',
                    hintStyle: TextStyle(
                        color: context.appTextMuted, fontSize: 13),
                    prefixIcon: Icon(Icons.search,
                        color: context.appTextMuted, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Icon(Icons.close,
                                color: context.appTextMuted, size: 18),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── Filter Chips ─────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Semua', 'Hari Ini', 'Minggu Ini'].map((f) {
                    final isActive = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _filter = f);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
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
                            f,
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
              const SizedBox(height: 16),

              // ── Loading ───────────────────────────────────────────────
              if (prov.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  ),
                )

              // ── Empty State ───────────────────────────────────────────
              else if (logs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Text('📋',
                            style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty || _filter != 'Semua'
                              ? 'Tidak ada workout ditemukan'
                              : 'Belum ada riwayat workout',
                          style: TextStyle(
                            color: context.appTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _searchQuery.isNotEmpty || _filter != 'Semua'
                              ? 'Coba ubah filter atau kata kunci'
                              : 'Tap tombol + untuk tambah workout',
                          style: TextStyle(
                            color: context.appTextMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // ── Log List dengan Swipe to Delete ──────────────────────
              else
                Container(
                  decoration: BoxDecoration(
                    color: context.appCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.appDivider),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: logs.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: context.appDivider, height: 1),
                    itemBuilder: (ctx, i) {
                      final log = logs[i];
                      final heroTag =
                          'workout-${log.firestoreId ?? log.id}';

                      return Dismissible(
                        key: Key(
                            log.firestoreId ?? log.id.toString()),
                        direction: DismissDirection.endToStart,
                        // Konfirmasi sebelum hapus
                        confirmDismiss: (_) async {
                          HapticFeedback.mediumImpact();
                          return await showDialog<bool>(
                            context: context,
                            builder: (dCtx) => AlertDialog(
                              backgroundColor: context.appCard,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text(
                                'Hapus Workout?',
                                style: TextStyle(
                                  color: context.appTextPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              content: Text(
                                '"${log.exercise}" akan dihapus permanen.',
                                style: TextStyle(
                                    color: context.appTextMuted,
                                    fontSize: 13),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dCtx, false),
                                  child: Text('Batal',
                                      style: TextStyle(
                                          color: context.appTextMuted)),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dCtx, true),
                                  child: const Text('Hapus',
                                      style: TextStyle(
                                          color: AppColors.danger,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) async {
                          HapticFeedback.heavyImpact();
                          SoundService.instance.playDelete();
                          await prov.deleteLog(log);
                          if (!context.mounted) return;
                          showSnack(context, '🗑 Workout dihapus!',
                              isError: true);
                        },
                        // Background saat swipe kiri
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding:
                              const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.danger.withValues(alpha: 0),
                                AppColors.danger,
                              ],
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_rounded,
                                  color: Colors.white, size: 26),
                              SizedBox(height: 4),
                              Text('Hapus',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ],
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            SoundService.instance.playNavigate();
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    WorkoutDetailScreen(log: log),
                                transitionsBuilder: (_, anim, __,
                                        child) =>
                                    FadeTransition(
                                        opacity: anim, child: child),
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // Hero icon
                                Hero(
                                  tag: heroTag,
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(log.icon,
                                          style: const TextStyle(
                                              fontSize: 20)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        log.exercise,
                                        style: TextStyle(
                                          color:
                                              context.appTextPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${log.date} · ${log.reps}x · ${log.duration}s · 🔥${log.calories} kal',
                                        style: TextStyle(
                                          color: context.appTextMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Edit button
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    showWorkoutLogModal(context,
                                        editing: log);
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text('✏',
                                          style:
                                              TextStyle(fontSize: 13)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Arrow indicator
                                Icon(
                                  Icons.chevron_right,
                                  color: context.appTextMuted,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        // ── FAB Tambah Workout ────────────────────────────────────────
        Positioned(
          right: 20,
          bottom: 20,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              showWorkoutLogModal(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('➕', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'Tambah Workout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mini Stat ─────────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label, value, icon;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
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
