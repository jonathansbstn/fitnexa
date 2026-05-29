import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';

class StreakCalendar extends StatefulWidget {
  /// Set tanggal yang ada workoutnya (format 'yyyy-MM-dd')
  final Set<String> workoutDates;
  const StreakCalendar({super.key, required this.workoutDates});

  @override
  State<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<StreakCalendar> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = DateTime(DateTime.now().year, DateTime.now().month);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _prev() => setState(
      () => _month = DateTime(_month.year, _month.month - 1));
  void _next() {
    final now = DateTime.now();
    if (_month.year < now.year ||
        (_month.year == now.year && _month.month < now.month)) {
      setState(() => _month = DateTime(_month.year, _month.month + 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(_month.year, _month.month, 1);
    final lastDay = DateTime(_month.year, _month.month + 1, 0);
    // startOffset: Mon=0, Tue=1, ..., Sun=6
    final startOffset = (firstDay.weekday - 1) % 7;
    final totalCells = startOffset + lastDay.day;
    final rows = (totalCells / 7).ceil();

    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    const dayHeaders = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Month Navigator ─────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _prev,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.appCardLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.chevron_left,
                    color: context.appTextMuted, size: 20),
              ),
            ),
            Text(
              '${monthNames[_month.month - 1]} ${_month.year}',
              style: TextStyle(
                color: context.appTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            GestureDetector(
              onTap: _next,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.appCardLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: (_month.year < now.year ||
                          (_month.year == now.year &&
                              _month.month < now.month))
                      ? context.appTextMuted
                      : context.appDivider,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Day Headers ─────────────────────────────────────────────────
        Row(
          children: dayHeaders.map((d) {
            return Expanded(
              child: Center(
                child: Text(
                  d,
                  style: TextStyle(
                    color: d == 'Min'
                        ? AppColors.danger.withValues(alpha: 0.7)
                        : context.appTextMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // ── Calendar Grid ───────────────────────────────────────────────
        ...List.generate(rows, (row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayNum = cellIndex - startOffset + 1;

                if (dayNum < 1 || dayNum > lastDay.day) {
                  return const Expanded(child: SizedBox());
                }

                final date = DateTime(_month.year, _month.month, dayNum);
                final dateStr = _fmt(date);
                final isToday = _fmt(now) == dateStr;
                final hasWorkout = widget.workoutDates.contains(dateStr);
                final isFuture = date.isAfter(now);

                return Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.primary
                            : hasWorkout
                                ? AppColors.primary.withValues(alpha: 0.25)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isToday
                            ? null
                            : hasWorkout
                                ? Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.6),
                                    width: 1.5,
                                  )
                                : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: TextStyle(
                              color: isToday
                                  ? Colors.white
                                  : isFuture
                                      ? context.appTextMuted
                                          .withValues(alpha: 0.3)
                                      : hasWorkout
                                          ? AppColors.primary
                                          : context.appTextMuted,
                              fontSize: 13,
                              fontWeight: isToday || hasWorkout
                                  ? FontWeight.w800
                                  : FontWeight.w400,
                            ),
                          ),
                          // Workout dot indicator
                          if (hasWorkout && !isToday)
                            Positioned(
                              bottom: 4,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),

        // ── Legend ─────────────────────────────────────────────────────
        const SizedBox(height: 12),
        Row(
          children: [
            _Legend(
              color: AppColors.primary,
              label: 'Hari ini',
              filled: true,
            ),
            const SizedBox(width: 16),
            _Legend(
              color: AppColors.primary.withValues(alpha: 0.6),
              label: 'Ada workout',
              filled: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final bool filled;
  const _Legend(
      {required this.color, required this.label, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: filled ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: filled ? null : Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: context.appTextMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
