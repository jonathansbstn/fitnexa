class Exercise {
  final int id;
  final String name;
  final String category;
  final int calories;
  final String icon;
  final String duration;
  final String reps;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.icon,
    required this.duration,
    required this.reps,
  });

  static const List<Exercise> all = [
    Exercise(
      id: 1,
      name: 'Push Up',
      category: 'Chest',
      calories: 8,
      icon: '💪',
      duration: '30s',
      reps: '15x',
    ),
    Exercise(
      id: 2,
      name: 'Squat',
      category: 'Legs',
      calories: 10,
      icon: '🦵',
      duration: '45s',
      reps: '20x',
    ),
    Exercise(
      id: 3,
      name: 'Plank',
      category: 'Core',
      calories: 5,
      icon: '🏋️',
      duration: '60s',
      reps: '1min',
    ),
    Exercise(
      id: 4,
      name: 'Jumping Jack',
      category: 'Cardio',
      calories: 12,
      icon: '⚡',
      duration: '30s',
      reps: '20x',
    ),
    Exercise(
      id: 5,
      name: 'Mountain Climber',
      category: 'Full Body',
      calories: 15,
      icon: '🏃',
      duration: '30s',
      reps: '20x',
    ),
    Exercise(
      id: 6,
      name: 'Burpee',
      category: 'Full Body',
      calories: 18,
      icon: '🔥',
      duration: '30s',
      reps: '10x',
    ),
    Exercise(
      id: 7,
      name: 'Lunges',
      category: 'Legs',
      calories: 9,
      icon: '🚶',
      duration: '40s',
      reps: '15x',
    ),
    Exercise(
      id: 8,
      name: 'Sit Up',
      category: 'Core',
      calories: 7,
      icon: '🎯',
      duration: '30s',
      reps: '20x',
    ),
  ];

  static Exercise? findById(int id) {
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

class AiRecommendation {
  final Exercise exercise;
  final String reason;
  const AiRecommendation({required this.exercise, required this.reason});
}

List<AiRecommendation> getRuleBased(String goal, String level, int duration) {
  final List<({int id, String reason})> recs = [];

  if (goal == 'fat_loss' && duration < 15) {
    recs.addAll([
      (id: 4, reason: 'Quick cardio untuk fat loss'),
      (id: 5, reason: 'High intensity fat burner'),
      (id: 6, reason: 'Full body calorie burner'),
    ]);
  } else if (level == 'beginner') {
    recs.addAll([
      (id: 1, reason: 'Perfect untuk pemula'),
      (id: 3, reason: 'Core strengthening ringan'),
      (id: 2, reason: 'Lower body toning'),
    ]);
  } else if (goal == 'muscle_gain') {
    recs.addAll([
      (id: 1, reason: 'Upper body strength'),
      (id: 2, reason: 'Leg power builder'),
      (id: 7, reason: 'Balance & leg toning'),
    ]);
  } else if (goal == 'endurance') {
    recs.addAll([
      (id: 4, reason: 'Cardio endurance boost'),
      (id: 5, reason: 'Full body stamina'),
      (id: 8, reason: 'Core endurance'),
    ]);
  } else {
    recs.addAll([
      (id: 1, reason: 'Latihan dasar terbaik'),
      (id: 4, reason: 'Cardio ringan'),
      (id: 3, reason: 'Core stability'),
    ]);
  }

  return recs
      .map((r) {
        final ex = Exercise.findById(r.id);
        if (ex == null) return null;
        return AiRecommendation(exercise: ex, reason: r.reason);
      })
      .whereType<AiRecommendation>()
      .toList();
}
