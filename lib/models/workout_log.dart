import 'dart:convert';

class WorkoutLog {
  final int id;
  final String date;
  final String exercise;
  final String icon;
  final int reps;
  final int duration;
  final int calories;
  // Firestore document ID (null untuk data lama/seed)
  final String? firestoreId;
  // Kategori exercise
  final String category;

  const WorkoutLog({
    required this.id,
    required this.date,
    required this.exercise,
    required this.icon,
    required this.reps,
    required this.duration,
    required this.calories,
    this.firestoreId,
    this.category = '',
  });

  WorkoutLog copyWith({
    int? id,
    String? date,
    String? exercise,
    String? icon,
    int? reps,
    int? duration,
    int? calories,
    String? firestoreId,
    String? category,
  }) =>
      WorkoutLog(
        id: id ?? this.id,
        date: date ?? this.date,
        exercise: exercise ?? this.exercise,
        icon: icon ?? this.icon,
        reps: reps ?? this.reps,
        duration: duration ?? this.duration,
        calories: calories ?? this.calories,
        firestoreId: firestoreId ?? this.firestoreId,
        category: category ?? this.category,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'exercise': exercise,
        'icon': icon,
        'reps': reps,
        'duration': duration,
        'calories': calories,
        'category': category,
      };

  // Untuk Firestore: tidak menyimpan firestoreId di dalam dokumen
  Map<String, dynamic> toFirestore() => {
        'id': id,
        'date': date,
        'exercise': exercise,
        'icon': icon,
        'reps': reps,
        'duration': duration,
        'calories': calories,
        'category': category,
        'createdAt': date,
        'updatedAt': date,
      };

  factory WorkoutLog.fromMap(Map<String, dynamic> m, {String? firestoreId}) =>
      WorkoutLog(
        id: (m['id'] as num?)?.toInt() ?? 0,
        date: m['date'] as String? ?? '',
        exercise: m['exercise'] as String? ?? '',
        icon: m['icon'] as String? ?? '🏋️',
        reps: (m['reps'] as num?)?.toInt() ?? 0,
        duration: (m['duration'] as num?)?.toInt() ?? 0,
        calories: (m['calories'] as num?)?.toInt() ?? 0,
        firestoreId: firestoreId,
        category: m['category'] as String? ?? '',
      );

  String toJson() => jsonEncode(toMap());
  factory WorkoutLog.fromJson(String src) =>
      WorkoutLog.fromMap(jsonDecode(src) as Map<String, dynamic>);

}
