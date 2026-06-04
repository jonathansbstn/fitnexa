import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_model.dart';
import '../models/workout_log.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

// ── Weekly bar data ──────────────────────────────────────────────────────
class WeeklyBar {
  final String day;
  final int calories;
  const WeeklyBar(this.day, this.calories);
}

// ── App State Provider ───────────────────────────────────────────────────
class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Auth
  String? _userName;
  String? _userEmail;
  String? _uid;
  String? _photoUrl;

  String get userName => _userName ?? 'Pengguna';
  String get userEmail => _userEmail ?? '';
  String? get uid => _uid;
  String? get photoUrl => _photoUrl;
  bool _isUploadingPhoto = false;
  bool get isUploadingPhoto => _isUploadingPhoto;
  String get userInitials {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
  }

  bool get isLoggedIn => _uid != null;

  // Onboarding
  bool _hasSeenOnboarding = false;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  Future<void> markOnboardingDone() async {
    _hasSeenOnboarding = true;
    final p = await SharedPreferences.getInstance();
    await p.setBool('has_seen_onboarding', true);
    notifyListeners();
  }

  // User Profile
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;
  bool get hasCompletedProfile => _userProfile != null;

  Future<void> saveUserProfile(UserProfile profile) async {
    _userProfile = profile;
    final p = await SharedPreferences.getInstance();
    await p.setString('user_profile', profile.toJson());

    // Juga simpan ke Firestore jika logged in
    if (_uid != null) {
      try {
        await _firestoreService.saveUserProfile(_uid!, profile);
      } catch (_) {
        // Fallback: sudah tersimpan lokal
      }
    }
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

  // Confetti State
  bool _showConfetti = false;
  bool get showConfetti => _showConfetti;
  void playConfetti() {
    _showConfetti = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 4), () {
      _showConfetti = false;
      notifyListeners();
    });
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

  // ── Auth (Firebase) ────────────────────────────────────────────────────
  Future<void> loginWithEmailPassword(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cred = await _authService.signInWithEmail(email, password);
      final user = cred.user!;
      _uid = user.uid;
      _userName = user.displayName ?? email.split('@')[0];
      _userEmail = user.email;

      final p = await SharedPreferences.getInstance();
      await p.setString('user_name', _userName!);
      await p.setString('user_email', _userEmail!);
      await p.setString('user_uid', _uid!);

      // Load data dari Firestore
      await _loadFromFirestore();
    } on String catch (e) {
      _errorMessage = e;
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerWithEmailPassword(
      String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cred = await _authService.registerWithEmail(name, email, password);
      final user = cred.user!;
      _uid = user.uid;
      _userName = name;
      _userEmail = user.email;
      _logs = []; // akun baru mulai kosong
      _userProfile = null; // belum ada profil

      final p = await SharedPreferences.getInstance();
      await p.setString('user_name', name);
      await p.setString('user_email', email);
      await p.setString('user_uid', _uid!);
      await p.remove('workout_logs');
      await p.remove('user_profile');
    } on String catch (e) {
      _errorMessage = e;
      rethrow;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login dengan Google — bisa dipakai user baru maupun lama
  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cred = await _authService.signInWithGoogle();
      final user = cred.user!;
      _uid = user.uid;
      _userName = user.displayName ?? user.email?.split('@')[0] ?? 'Pengguna';
      _userEmail = user.email;
      _photoUrl = user.photoURL;

      final p = await SharedPreferences.getInstance();
      await p.setString('user_name', _userName!);
      await p.setString('user_email', _userEmail ?? '');
      await p.setString('user_uid', _uid!);
      if (_photoUrl != null) await p.setString('user_photo_url', _photoUrl!);

      // Load data dari Firestore
      await _loadFromFirestore();
    } on String catch (e) {
      _errorMessage = e;
      rethrow;
    } catch (e) {
      _errorMessage = 'Gagal login dengan Google. Coba lagi.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload foto profil dari galeri/kamera
  Future<void> uploadProfilePhoto(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null) return;
    if (_uid == null) return;

    _isUploadingPhoto = true;
    notifyListeners();

    try {
      final file = File(picked.path);
      final url = await StorageService.instance.uploadProfilePhoto(_uid!, file);
      _photoUrl = url;

      // Simpan di Firebase Auth
      try { await _authService.updatePhotoURL(url); } catch (_) {}

      // Simpan di Firestore
      try { await _firestoreService.savePhotoUrl(_uid!, url); } catch (_) {}

      // Simpan lokal
      final p = await SharedPreferences.getInstance();
      await p.setString('user_photo_url', url);
    } catch (e) {
      _errorMessage = 'Gagal upload foto: ${e.toString()}';
    } finally {
      _isUploadingPhoto = false;
      notifyListeners();
    }
  }

  /// Hapus foto profil
  Future<void> deleteProfilePhoto() async {
    if (_uid == null) return;
    _isUploadingPhoto = true;
    notifyListeners();
    try {
      await StorageService.instance.deleteProfilePhoto(_uid!);
      try { await _firestoreService.deletePhotoUrl(_uid!); } catch (_) {}
      _photoUrl = null;
      final p = await SharedPreferences.getInstance();
      await p.remove('user_photo_url');
    } catch (_) {}
    _isUploadingPhoto = false;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (_) {}

    _userName = null;
    _userEmail = null;
    _uid = null;
    _photoUrl = null;
    _logs = [];
    _userProfile = null;

    final p = await SharedPreferences.getInstance();
    await p.remove('user_name');
    await p.remove('user_email');
    await p.remove('user_uid');
    await p.remove('user_profile');
    await p.remove('user_photo_url');
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    _userName = name;
    final p = await SharedPreferences.getInstance();
    await p.setString('user_name', name);

    // Update di Firebase juga
    try {
      await _authService.updateDisplayName(name);
    } catch (_) {}
    notifyListeners();
  }

  // Dipanggil dari splash jika sudah ada sesi
  Future<void> initializeAuth() async {
    // Cek apakah Firebase user masih valid
    final user = _authService.currentUser;
    if (user != null) {
      _uid = user.uid;
      _userName = user.displayName ?? _userName;
      _userEmail = user.email ?? _userEmail;

      // Refresh data dari Firestore
      try {
        await _loadFromFirestore();
      } catch (_) {
        // Fallback ke data lokal yang sudah dimuat dari prefs
      }
    }
    notifyListeners();
  }

  // ── Load dari Firestore ──────────────────────────────────────────────────
  Future<void> _loadFromFirestore() async {
    if (_uid == null) return;

    try {
      // Load logs
      final firestoreLogs = await _firestoreService.getWorkoutLogs(_uid!);
      if (firestoreLogs.isNotEmpty) {
        _logs = firestoreLogs;
        await _saveLogs(); // sync ke local
      } else {
        // Migrasi data lokal ke Firestore jika ada
        if (_logs.isNotEmpty) {
          await _firestoreService.migrateLogsToFirestore(_uid!, _logs);
          // Reload untuk mendapatkan firestoreId
          _logs = await _firestoreService.getWorkoutLogs(_uid!);
          await _saveLogs();
        }
      }

      // Load profile dari Firestore
      final firestoreProfile =
          await _firestoreService.getUserProfile(_uid!);
      if (firestoreProfile != null) {
        _userProfile = firestoreProfile;
        final p = await SharedPreferences.getInstance();
        await p.setString('user_profile', firestoreProfile.toJson());
      }

      // Load photoUrl dari Firestore
      try {
        final userDoc = await _firestoreService.getUserDoc(_uid!);
        final photoUrl = userDoc?['photoUrl'] as String?;
        if (photoUrl != null && photoUrl.isNotEmpty) {
          _photoUrl = photoUrl;
          final p = await SharedPreferences.getInstance();
          await p.setString('user_photo_url', photoUrl);
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('Firestore load error: $e');
      // Lanjutkan dengan data lokal
    }
  }

  // ── Logs CRUD (Firestore + Local Cache) ──────────────────────────────────
  Future<void> loadLogs() async {
    if (_uid != null) {
      try {
        _logs = await _firestoreService.getWorkoutLogs(_uid!);
        await _saveLogs();
        notifyListeners();
        return;
      } catch (_) {}
    }
    // Fallback ke SharedPreferences
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList('workout_logs');
    if (raw != null && raw.isNotEmpty) {
      _logs = raw.map((s) => WorkoutLog.fromJson(s)).toList();
    }
    notifyListeners();
  }

  /// Refresh logs — used by Pull to Refresh
  Future<void> refreshLogs() async {
    await loadLogs();
  }

  Future<void> addLog(WorkoutLog log) async {
    // Tambah ke Firestore terlebih dahulu untuk mendapatkan ID
    if (_uid != null) {
      try {
        final docId = await _firestoreService.addWorkoutLog(_uid!, log);
        log = log.copyWith(firestoreId: docId);
      } catch (_) {}
    }
    _logs = [log, ..._logs];
    await _saveLogs();
    playConfetti(); // Trigger ledakan confetti!
    notifyListeners();
  }

  Future<void> updateLog(WorkoutLog updated) async {
    // Update di Firestore
    if (_uid != null && updated.firestoreId != null) {
      try {
        await _firestoreService.updateWorkoutLog(
            _uid!, updated.firestoreId!, updated);
      } catch (_) {}
    }
    _logs = _logs.map((l) => l.id == updated.id ? updated : l).toList();
    await _saveLogs();
    notifyListeners();
  }

  Future<void> deleteLog(WorkoutLog log) async {
    // Hapus di Firestore
    if (_uid != null && log.firestoreId != null) {
      try {
        await _firestoreService.deleteWorkoutLog(
            _uid!, log.firestoreId!);
      } catch (_) {}
    }
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
    _uid = p.getString('user_uid');
    _photoUrl = p.getString('user_photo_url');
    _isDarkMode = p.getBool('dark_mode') ?? true;
    _hasSeenOnboarding = p.getBool('has_seen_onboarding') ?? false;
    _targetCalories = p.getInt('target_calories') ?? 500;

    // Load user profile dari SharedPreferences
    final profileJson = p.getString('user_profile');
    if (profileJson != null && profileJson.isNotEmpty) {
      try {
        _userProfile = UserProfile.fromJson(profileJson);
      } catch (_) {}
    }

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
