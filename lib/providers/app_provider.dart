import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_model.dart';
import '../models/workout_log.dart';

// ── Weekly bar data ──────────────────────────────────────────────────────
class WeeklyBar {
  final String day;
  final int calories;
  const WeeklyBar(this.day, this.calories);
}

// ── App State Provider ───────────────────────────────────────────────────
class AppProvider extends ChangeNotifier {
  // Auth (demo/lokal)
  String? _userName;
  String? _userEmail;

  String get userName => _userName ?? 'Pengguna';
  String get userEmail => _userEmail ?? '';
  String get userInitials {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
  }

  bool get isLoggedIn => _userName != null;

  // Onboarding
  bool _hasSeenOnboarding = false;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  Future<void> markOnboardingDone() async {
    _hasSeenOnboarding = true;
    final p = await SharedPreferences.getInstance();
    await p.setBool('has_seen_onboarding', true);
    notifyListeners();
  }

  // Target kalori harian
  int _targetCalories = 500;
  int get targetCalories => _targetCalories;
  Future<void> setTargetCalories(int t) async {
    _targetCalories = t;
    final p = await SharedPreferences.getInstance();
    await p.setInt('target_calories', t);
    notifyListeners();
  }

  // Kalori hari ini
  int get todayCalories {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _logs
        .where((l) => l.date == todayStr)
        .fold(0, (s, l) => s + l.calories);
  }

  // Loading & Error state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Theme
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;
  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final p = await SharedPreferences.getInstance();
    await p.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  // Logs
  List<WorkoutLog> _logs = [];
  List<WorkoutLog> get logs => _logs;
  int get totalCalories => _logs.fold(0, (s, l) => s + l.calories);
  int get totalDuration => _logs.fold(0, (s, l) => s + l.duration);
  int get streak => _calcStreak();

  // Timer
  Exercise? _activeWorkout;
  Exercise? get activeWorkout => _activeWorkout;
  int _timerSeconds = 0;
  int get timerSeconds => _timerSeconds;
  int _targetSeconds = 0;
  int get targetSeconds => _targetSeconds;
  double get timerProgress =>
      _targetSeconds > 0 ? (_timerSeconds / _targetSeconds).clamp(0.0, 1.0) : 0.0;
  bool _timerRunning = false;
  bool get timerRunning => _timerRunning;
  Timer? _timer;

  // State selesai workout — untuk trigger confetti di UI
  bool _workoutJustFinished = false;
  bool get workoutJustFinished => _workoutJustFinished;
  void resetWorkoutFinished() {
    _workoutJustFinished = false;
    notifyListeners();
  }

  // AI
  String _aiGoal = 'fat_loss';
  String _aiLevel = 'beginner';
  int _aiDuration = 20;
  List<AiRecommendation> _aiRecs = [];
  String get aiGoal => _aiGoal;
  String get aiLevel => _aiLevel;
  int get aiDuration => _aiDuration;
  List<AiRecommendation> get aiRecs => _aiRecs;

  AppProvider() {
    _loadFromPrefs();
  }

  // ── Weekly computed data (dari logs asli) ────────────────────────────────
  List<WeeklyBar> get weeklyData {
    final now = DateTime.now();
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dateStr =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final cal = _logs
          .where((l) => l.date == dateStr)
          .fold(0, (s, l) => s + l.calories);
      final dayName = days[day.weekday - 1];
      return WeeklyBar(dayName, cal);
    });
  }

  // ── Auth (Demo — terima email & password apapun) ──────────────────────────
  Future<void> loginWithEmailPassword(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Demo: gunakan bagian sebelum @ sebagai nama
    final name = email.split('@')[0];
    _userName = name;
    _userEmail = email;

    final p = await SharedPreferences.getInstance();
    await p.setString('user_name', name);
    await p.setString('user_email', email);

    // Load logs setelah login (mulai kosong jika belum ada data)
    final raw = p.getStringList('workout_logs');
    if (raw != null && raw.isNotEmpty) {
      _logs = raw.map((s) => WorkoutLog.fromJson(s)).toList();
    } else {
      _logs = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> registerWithEmailPassword(
      String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _userName = name;
    _userEmail = email;
    _logs = []; // akun baru mulai kosong

    final p = await SharedPreferences.getInstance();
    await p.setString('user_name', name);
    await p.setString('user_email', email);
    // Hapus logs lama supaya akun baru bersih
    await p.remove('workout_logs');

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _userName = null;
    _userEmail = null;
    _logs = [];
    final p = await SharedPreferences.getInstance();
    await p.remove('user_name');
    await p.remove('user_email');
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    _userName = name;
    final p = await SharedPreferences.getInstance();
    await p.setString('user_name', name);
    notifyListeners();
  }

  // Dipanggil dari splash jika sudah ada sesi
  Future<void> initializeAuth() async {
    // Sudah diload dari _loadFromPrefs, tidak perlu action tambahan
    notifyListeners();
  }

  // ── Logs CRUD (SharedPreferences) ───────────────────────────────────────
  Future<void> loadLogs() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList('workout_logs');
    if (raw != null && raw.isNotEmpty) {
      _logs = raw.map((s) => WorkoutLog.fromJson(s)).toList();
    }
    notifyListeners();
  }

  Future<void> addLog(WorkoutLog log) async {
    _logs = [log, ..._logs];
    await _saveLogs();
    notifyListeners();
  }

  Future<void> updateLog(WorkoutLog updated) async {
    _logs = _logs.map((l) => l.id == updated.id ? updated : l).toList();
    await _saveLogs();
    notifyListeners();
  }

  Future<void> deleteLog(WorkoutLog log) async {
    _logs = _logs.where((l) => l.id != log.id).toList();
    await _saveLogs();
    notifyListeners();
  }

  int get nextId =>
      _logs.isEmpty ? 1 : (_logs.map((l) => l.id).reduce((a, b) => a > b ? a : b) + 1);

  // ── Timer ───────────────────────────────────────────────────────────────
  int _parseDuration(String durationStr) {
    if (durationStr.endsWith('s')) {
      return int.tryParse(durationStr.replaceAll('s', '')) ?? 0;
    } else if (durationStr.endsWith('min')) {
      return (int.tryParse(durationStr.replaceAll('min', '')) ?? 0) * 60;
    }
    return 0;
  }

  void startWorkout(Exercise ex) {
    _activeWorkout = ex;
    _timerSeconds = 0;
    _timerRunning = true;
    _timer?.cancel();
    _targetSeconds = _parseDuration(ex.duration);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timerRunning) {
        _timerSeconds++;
        if (_targetSeconds > 0 && _timerSeconds >= _targetSeconds) {
          finishWorkout();
        } else {
          notifyListeners();
        }
      }
    });
    notifyListeners();
  }

  void pauseResumeTimer() {
    _timerRunning = !_timerRunning;
    if (_timerRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _timerSeconds++;
        notifyListeners();
      });
    } else {
      _timer?.cancel();
    }
    notifyListeners();
  }

  void finishWorkout() {
    _timer?.cancel();
    _timerRunning = false;

    if (_activeWorkout != null) {
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      int repsInt = 0;
      if (_activeWorkout!.reps.endsWith('x')) {
        repsInt = int.tryParse(_activeWorkout!.reps.replaceAll('x', '')) ?? 1;
      } else {
        repsInt = 1;
      }

      final log = WorkoutLog(
        id: nextId,
        date: dateStr,
        exercise: _activeWorkout!.name,
        icon: _activeWorkout!.icon,
        reps: repsInt,
        duration: _timerSeconds,
        calories: _activeWorkout!.calories,
        category: _activeWorkout!.category,
      );

      addLog(log);

      // Set flag untuk trigger confetti di UI
      _workoutJustFinished = true;
    }

    _activeWorkout = null;
    _timerSeconds = 0;
    notifyListeners();
  }

  String get timerFormatted {
    final m = _timerSeconds ~/ 60;
    final s = _timerSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── AI ──────────────────────────────────────────────────────────────────
  void setAiGoal(String g) {
    _aiGoal = g;
    notifyListeners();
  }

  void setAiLevel(String l) {
    _aiLevel = l;
    notifyListeners();
  }

  void setAiDuration(int d) {
    _aiDuration = d;
    notifyListeners();
  }

  void generateAI() {
    _aiRecs = getRuleBased(_aiGoal, _aiLevel, _aiDuration);
    notifyListeners();
  }

  // ── Streak Calculation ───────────────────────────────────────────────────
  int _calcStreak() {
    if (_logs.isEmpty) return 0;
    final dates = _logs
        .map((l) => l.date)
        .toSet()
        .map((d) => DateTime.tryParse(d))
        .whereType<DateTime>()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) return 0;
    int streak = 1;
    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i - 1].difference(dates[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  // ── Persistence ──────────────────────────────────────────────────────────
  Future<void> _loadFromPrefs() async {
    final p = await SharedPreferences.getInstance();
    _userName = p.getString('user_name');
    _userEmail = p.getString('user_email');
    _isDarkMode = p.getBool('dark_mode') ?? true;
    _hasSeenOnboarding = p.getBool('has_seen_onboarding') ?? false;
    _targetCalories = p.getInt('target_calories') ?? 500;

    if (_userName != null) {
      final raw = p.getStringList('workout_logs');
      if (raw != null && raw.isNotEmpty) {
        _logs = raw.map((s) => WorkoutLog.fromJson(s)).toList();
      } else {
        // Akun baru mulai kosong, tidak ada seed data
        _logs = [];
      }
    }
    notifyListeners();
  }

  Future<void> _saveLogs() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
      'workout_logs',
      _logs.map((l) => l.toJson()).toList(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
