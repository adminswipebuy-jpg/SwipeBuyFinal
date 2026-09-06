import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MediaService {
  static final _storage = FirebaseStorage.instance;

  static Future<String> uploadVideo(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('You must be signed in.');

    final name = '${DateTime.now().millisecondsSinceEpoch}.mp4';
    final ref = _storage.ref('users/${user.uid}/videos/$name');

    final task = ref.putFile(
      file,
      SettableMetadata(contentType: 'video/mp4'),
    );
    await task;
    return ref.getDownloadURL();
  }

  static Future<String> uploadImage(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('You must be signed in.');

    final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref('users/${user.uid}/media/$name');
    final task = ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    await task;
    return ref.getDownloadURL();
  }

  static Future<String> uploadProfileImage(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('You must be signed in.');

    final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref('users/${user.uid}/profile/$name');

    final task = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    await task;
    return ref.getDownloadURL();
  }
}
