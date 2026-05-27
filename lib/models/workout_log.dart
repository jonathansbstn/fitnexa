import 'dart:convert';

class WorkoutLog {
  final int id;
  final String date;
  final String exercise;
  final String icon;
  final int reps;
  final int duration;
  final int calories;

  const WorkoutLog({
    required this.id,
    required this.date,
    required this.exercise,
    required this.icon,
    required this.reps,
    required this.duration,
    required this.calories,
  });

  WorkoutLog copyWith({
    int? id,
    String? date,
    String? exercise,
    String? icon,
    int? reps,
    int? duration,
    int? calories,
  }) => WorkoutLog(
    id: id ?? this.id,
    date: date ?? this.date,
    exercise: exercise ?? this.exercise,
    icon: icon ?? this.icon,
    reps: reps ?? this.reps,
    duration: duration ?? this.duration,
    calories: calories ?? this.calories,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'exercise': exercise,
    'icon': icon,
    'reps': reps,
    'duration': duration,
    'calories': calories,
  };

  factory WorkoutLog.fromMap(Map<String, dynamic> m) => WorkoutLog(
    id: m['id'] as int,
    date: m['date'] as String,
    exercise: m['exercise'] as String,
    icon: m['icon'] as String? ?? '🏋️',
    reps: m['reps'] as int,
    duration: m['duration'] as int,
    calories: m['calories'] as int,
  );

  String toJson() => jsonEncode(toMap());
  factory WorkoutLog.fromJson(String src) =>
      WorkoutLog.fromMap(jsonDecode(src) as Map<String, dynamic>);

  // ── Seed data (mirrors INITIAL_LOGS from JSX) ────────────────────────
  static final List<WorkoutLog> seedData = [
    const WorkoutLog(
      id: 1,
      date: '2026-05-12',
      exercise: 'Push Up',
      icon: '💪',
      reps: 15,
      duration: 30,
      calories: 8,
    ),
    const WorkoutLog(
      id: 2,
      date: '2026-05-12',
      exercise: 'Squat',
      icon: '🦵',
      reps: 20,
      duration: 45,
      calories: 10,
    ),
    const WorkoutLog(
      id: 3,
      date: '2026-05-11',
      exercise: 'Plank',
      icon: '🏋️',
      reps: 1,
      duration: 60,
      calories: 5,
    ),
    const WorkoutLog(
      id: 4,
      date: '2026-05-11',
      exercise: 'Jumping Jack',
      icon: '⚡',
      reps: 20,
      duration: 30,
      calories: 12,
    ),
    const WorkoutLog(
      id: 5,
      date: '2026-05-10',
      exercise: 'Mountain Climber',
      icon: '🏃',
      reps: 20,
      duration: 30,
      calories: 15,
    ),
    const WorkoutLog(
      id: 6,
      date: '2026-05-10',
      exercise: 'Burpee',
      icon: '🔥',
      reps: 10,
      duration: 30,
      calories: 18,
    ),
    const WorkoutLog(
      id: 7,
      date: '2026-05-09',
      exercise: 'Sit Up',
      icon: '🎯',
      reps: 20,
      duration: 30,
      calories: 7,
    ),
  ];
}
