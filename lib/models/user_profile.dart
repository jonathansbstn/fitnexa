import 'dart:convert';

class UserProfile {
  final String gender; // 'pria' or 'wanita'
  final double weight; // kg
  final double height; // cm
  final String fitnessGoal; // 'fat_loss', 'muscle_gain', 'endurance', 'general'

  const UserProfile({
    required this.gender,
    required this.weight,
    required this.height,
    required this.fitnessGoal,
  });

  Map<String, dynamic> toMap() => {
        'gender': gender,
        'weight': weight,
        'height': height,
        'fitnessGoal': fitnessGoal,
      };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        gender: m['gender'] as String? ?? 'pria',
        weight: (m['weight'] as num?)?.toDouble() ?? 60.0,
        height: (m['height'] as num?)?.toDouble() ?? 165.0,
        fitnessGoal: m['fitnessGoal'] as String? ?? 'general',
      );

  String toJson() => jsonEncode(toMap());
  factory UserProfile.fromJson(String src) =>
      UserProfile.fromMap(jsonDecode(src) as Map<String, dynamic>);

  // BMI calculation
  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  String get genderLabel => gender == 'pria' ? 'Pria' : 'Wanita';

  String get goalLabel {
    switch (fitnessGoal) {
      case 'fat_loss':
        return 'Fat Loss';
      case 'muscle_gain':
        return 'Muscle Gain';
      case 'endurance':
        return 'Endurance';
      default:
        return 'General Fitness';
    }
  }

  String get bmiEmoji {
    if (bmi < 18.5) return '⚠️';
    if (bmi < 25) return '✅';
    if (bmi < 30) return '⚠️';
    return '🔴';
  }

  String get genderEmoji => gender == 'pria' ? '🧑' : '👩';

  String get goalEmoji {
    switch (fitnessGoal) {
      case 'fat_loss':
        return '🔥';
      case 'muscle_gain':
        return '💪';
      case 'endurance':
        return '🏃';
      default:
        return '⭐';
    }
  }
}
