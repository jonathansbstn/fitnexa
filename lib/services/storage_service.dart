import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload foto profil user ke Firebase Storage.
  /// Returns download URL string.
  Future<String> uploadProfilePhoto(String uid, File imageFile) async {
    final ref = _storage
        .ref()
        .child('profile_photos')
        .child('$uid.jpg');

    final uploadTask = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  /// Hapus foto profil dari Firebase Storage.
  Future<void> deleteProfilePhoto(String uid) async {
    try {
      final ref = _storage
          .ref()
          .child('profile_photos')
          .child('$uid.jpg');
      await ref.delete();
    } catch (_) {
      // File mungkin tidak ada, abaikan error
    }
  }
}
