import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CommunityMediaService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> posts(String communityId) =>
      _db.collection('communities').doc(communityId).collection('posts')
          .orderBy('createdAt', descending: true).limit(50).snapshots();

  Future<String> upload(File file, {required bool video}) async {
    if (uid.isEmpty) throw StateError('You must be signed in.');
    final ext = video ? 'mp4' : 'jpg';
    final ref = _storage.ref('users/$uid/community/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: video ? 'video/mp4' : 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<String> createPost({
    required String communityId,
    required String text,
    String? mediaUrl,
    String type = 'text',
    List<String> pollOptions = const [],
  }) async {
    if (uid.isEmpty) throw StateError('You must be signed in.');
    final ref = _db.collection('communities').doc(communityId).collection('posts').doc();
    await ref.set({
      'authorId': uid,
      'text': text.trim(),
      'type': type,
      'mediaUrl': mediaUrl,
      'pollOptions': pollOptions,
      'pollVotes': <String, dynamic>{},
      'reactionCount': 0,
      'commentCount': 0,
      'status': 'published',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> react({required String communityId, required String postId, required String emoji}) async {
    if (uid.isEmpty) return;
    final ref = _db.collection('communities').doc(communityId).collection('posts').doc(postId);
    await ref.set({'reactions.$uid': emoji, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  Future<void> votePoll({required String communityId, required String postId, required String option}) async {
    if (uid.isEmpty) return;
    final ref = _db.collection('communities').doc(communityId).collection('posts').doc(postId);
    await ref.set({'pollVotes.$uid': option, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  Future<void> reportPost({required String communityId, required String postId, required String reason}) async {
    if (uid.isEmpty) return;
    await _db.collection('community_reports').add({
      'reporterId': uid,
      'communityId': communityId,
      'postId': postId,
      'reason': reason,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
