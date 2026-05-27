import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise_model.dart';
import '../models/workout_log.dart';

const _uuid = Uuid();

// ── Weekly bar data ──────────────────────────────────────────────────────
class WeeklyBar {
  final String day;
  final int calories;
  const WeeklyBar(this.day, this.calories);
}

const weeklyData = [
  WeeklyBar('Sen', 85),
  WeeklyBar('Sel', 60),
  WeeklyBar('Rab', 110),
  WeeklyBar('Kam', 30),
  WeeklyBar('Jum', 90),
  WeeklyBar('Sab', 140),
  WeeklyBar('Min', 55),
];

// ── App State Provider ───────────────────────────────────────────────────
class AppProvider extends ChangeNotifier {
  // Auth
  String? _userName;
  String? _userEmail;
  String get userName => _userName ?? 'Pengguna';
  String get userEmail => _userEmail ?? '';
  String get userInitials {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
  }

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
  List<WorkoutLog> _logs = List.from(WorkoutLog.seedData);
  List<WorkoutLog> get logs => _logs;
  int get totalCalories => _logs.fold(0, (s, l) => s + l.calories);
  int get totalDuration => _logs.fold(0, (s, l) => s + l.duration);
  int get streak => 7;

  // Timer
  Exercise? _activeWorkout;
  Exercise? get activeWorkout => _activeWorkout;
  int _timerSeconds = 0;
  int get timerSeconds => _timerSeconds;
  int _targetSeconds = 0;
  int get targetSeconds => _targetSeconds;
  double get timerProgress => _targetSeconds > 0 ? (_timerSeconds / _targetSeconds).clamp(0.0, 1.0) : 0.0;
  bool _timerRunning = false;
  bool get timerRunning => _timerRunning;
  Timer? _timer;

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

  // ── Auth ────────────────────────────────────────────────────────────────
  Future<void> login(String name, String email) async {
    _userName = name;
    _userEmail = email;
    final p = await SharedPreferences.getInstance();
    await p.setString('user_name', name);
    await p.setString('user_email', email);
    notifyListeners();
  }

  Future<void> logout() async {
    _userName = null;
    _userEmail = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('user_name');
    await p.remove('user_email');
    notifyListeners();
  }

  bool get isLoggedIn => _userName != null;

  // ── Logs CRUD ───────────────────────────────────────────────────────────
  void addLog(WorkoutLog log) {
    _logs = [log, ..._logs];
    _saveLogs();
    notifyListeners();
  }

  void updateLog(WorkoutLog updated) {
    _logs = _logs.map((l) => l.id == updated.id ? updated : l).toList();
    _saveLogs();
    notifyListeners();
  }

  void deleteLog(int id) {
    _logs = _logs.where((l) => l.id != id).toList();
    _saveLogs();
    notifyListeners();
  }

  int get nextId => _logs.isEmpty
      ? 1
      : (_logs.map((l) => l.id).reduce((a, b) => a > b ? a : b) + 1);

  // ── Timer ───────────────────────────────────────────────────────────────
  // Helper to parse duration
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
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
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
      );
      
      addLog(log);
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

  // ── Persistence ─────────────────────────────────────────────────────────
  Future<void> _loadFromPrefs() async {
    final p = await SharedPreferences.getInstance();
    _userName = p.getString('user_name');
    _userEmail = p.getString('user_email');
    _isDarkMode = p.getBool('dark_mode') ?? true;

    final raw = p.getStringList('workout_logs');
    if (raw != null && raw.isNotEmpty) {
      _logs = raw.map((s) => WorkoutLog.fromJson(s)).toList();
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
