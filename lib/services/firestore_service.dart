import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_log.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection references ──────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _logsCollection(String uid) =>
      _db.collection('users').doc(uid).collection('workout_logs');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  // ── Workout Logs CRUD ──────────────────────────────────────────────
  
  /// Add a new workout log, returns the Firestore document ID
  Future<String> addWorkoutLog(String uid, WorkoutLog log) async {
    final docRef = await _logsCollection(uid).add(log.toFirestore());
    return docRef.id;
  }

  /// Get all workout logs for a user, ordered by date descending
  Future<List<WorkoutLog>> getWorkoutLogs(String uid) async {
    final snapshot = await _logsCollection(uid)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => WorkoutLog.fromMap(doc.data(), firestoreId: doc.id))
        .toList();
  }

  /// Update a workout log by Firestore document ID
  Future<void> updateWorkoutLog(
      String uid, String docId, WorkoutLog log) async {
    await _logsCollection(uid).doc(docId).update(log.toFirestore());
  }

  /// Delete a workout log by Firestore document ID
  Future<void> deleteWorkoutLog(String uid, String docId) async {
    await _logsCollection(uid).doc(docId).delete();
  }

  // ── User Profile ───────────────────────────────────────────────────
  
  /// Save or update user profile
  Future<void> saveUserProfile(String uid, UserProfile profile) async {
    await _userDoc(uid).set({
      ...profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get user profile, returns null if not found
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromMap(doc.data()!);
  }

  /// Get raw user document data (includes photoUrl, etc.)
  Future<Map<String, dynamic>?> getUserDoc(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Save or update profile photo URL
  Future<void> savePhotoUrl(String uid, String photoUrl) async {
    await _userDoc(uid).set({
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Delete profile photo URL from Firestore
  Future<void> deletePhotoUrl(String uid) async {
    await _userDoc(uid).update({'photoUrl': FieldValue.delete()});
  }

  /// Check if user has completed profile setup
  Future<bool> hasCompletedProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists || doc.data() == null) return false;
    final data = doc.data()!;
    return data.containsKey('gender') && data.containsKey('weight');
  }

  // ── Batch Migration ────────────────────────────────────────────────
  
  /// Migrate local logs to Firestore (one-time migration)
  Future<void> migrateLogsToFirestore(
      String uid, List<WorkoutLog> localLogs) async {
    final batch = _db.batch();
    for (final log in localLogs) {
      final docRef = _logsCollection(uid).doc();
      batch.set(docRef, log.toFirestore());
    }
    await batch.commit();
  }
}
