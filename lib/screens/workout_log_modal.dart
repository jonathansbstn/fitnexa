import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';
import '../providers/app_provider.dart';
import '../models/exercise_model.dart';
import '../models/workout_log.dart';
import '../widgets/gradient_button.dart';
import '../widgets/snack_helper.dart';

void showWorkoutLogModal(BuildContext context, {WorkoutLog? editing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => WorkoutLogModal(editing: editing),
  );
}

class WorkoutLogModal extends StatefulWidget {
  final WorkoutLog? editing;
  const WorkoutLogModal({super.key, this.editing});
  @override
  State<WorkoutLogModal> createState() => _WorkoutLogModalState();
}

class _WorkoutLogModalState extends State<WorkoutLogModal> {
  String? _selectedExercise;
  final _repsCtrl = TextEditingController();
  final _durCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      _selectedExercise = widget.editing!.exercise;
      _repsCtrl.text = widget.editing!.reps.toString();
      _durCtrl.text = widget.editing!.duration.toString();
    }
  }

  @override
  void dispose() {
    _repsCtrl.dispose();
    _durCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_selectedExercise == null ||
        _repsCtrl.text.isEmpty ||
        _durCtrl.text.isEmpty) {
      showSnack(context, 'Semua field wajib diisi!', isError: true);
      return;
    }
    final prov = context.read<AppProvider>();
    final ex = Exercise.all.firstWhere((e) => e.name == _selectedExercise);
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (widget.editing != null) {
      prov.updateLog(
        widget.editing!.copyWith(
          exercise: _selectedExercise,
          icon: ex.icon,
          reps: int.tryParse(_repsCtrl.text) ?? 0,
          duration: int.tryParse(_durCtrl.text) ?? 0,
          calories: ex.calories,
        ),
      );
      showSnack(context, 'Workout berhasil diperbarui! ✓');
    } else {
      prov.addLog(
        WorkoutLog(
          id: prov.nextId,
          date: dateStr,
          exercise: _selectedExercise!,
          icon: ex.icon,
          reps: int.tryParse(_repsCtrl.text) ?? 0,
          duration: int.tryParse(_durCtrl.text) ?? 0,
          calories: ex.calories,
        ),
      );
      showSnack(context, 'Workout berhasil ditambahkan! 🎉');
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editing != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.appCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: context.appDivider),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appCardLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit Workout' : 'Tambah Workout',
                  style: TextStyle(
                    color: context.appTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: context.appCardLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '✕',
                        style: TextStyle(
                          color: context.appTextMuted,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Exercise Dropdown
            Text(
              'Jenis Latihan',
              style: TextStyle(
                color: context.appTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: context.appCardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.appDivider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedExercise,
                  dropdownColor: context.appCard,
                  hint: Text(
                    'Pilih latihan...',
                    style: TextStyle(
                      color: context.appTextMuted,
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(
                    color: context.appTextPrimary,
                    fontSize: 14,
                  ),
                  isExpanded: true,
                  onChanged: (v) => setState(() => _selectedExercise = v),
                  items: Exercise.all
                      .map(
                        (ex) => DropdownMenuItem(
                          value: ex.name,
                          child: Text('${ex.icon} ${ex.name}'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Reps & Duration
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'Repetisi',
                    hint: 'mis: 15',
                    ctrl: _repsCtrl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    label: 'Durasi (detik)',
                    hint: 'mis: 30',
                    ctrl: _durCtrl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            GradientButton(
              label: isEdit ? 'Simpan Perubahan ✓' : 'Simpan Workout 💾',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  const _Field({required this.label, required this.hint, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.appTextMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: context.appTextPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
