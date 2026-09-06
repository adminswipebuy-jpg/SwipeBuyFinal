import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatorContentService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  Future<String> createPost({
    required String text,
    required String category,
    String? mediaUrl,
    String mediaType = 'text',
    String? actionLabel,
    String? actionType,
  }) async {
    if (_uid.isEmpty) throw StateError('You must be signed in.');
    final user = _auth.currentUser!;
    final ref = _db.collection('content_items').doc();
    await ref.set({
      'title': text.trim().isEmpty ? 'SwipeBuy post' : text.trim(),
      'summary': text.trim(),
      'creator': user.displayName?.trim().isNotEmpty == true ? user.displayName : 'SwipeBuy Creator',
      'creatorId': _uid,
      'category': category,
      'location': 'Worldwide',
      'contentType': mediaType,
      'mediaUrl': mediaUrl,
      'status': 'published',
      'verified': false,
      'likes': 0,
      'comments': 0,
      'shares': 0,
      'actionLabel': actionLabel ?? 'View',
      'actionType': actionType ?? 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> toggleFollow(String creatorId) async {
    if (_uid.isEmpty || creatorId.isEmpty || creatorId == _uid) return;
    final ref = _db.collection('follows').doc('${_uid}_$creatorId');
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'followerId': _uid,
        'providerId': creatorId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<bool> isFollowing(String creatorId) {
    if (_uid.isEmpty || creatorId.isEmpty) return const Stream<bool>.empty();
    return _db.collection('follows').doc('${_uid}_$creatorId').snapshots().map((s) => s.exists);
  }

  Future<void> toggleLike(String contentId) async {
    if (_uid.isEmpty) return;
    final ref = _db.collection('content_likes').doc('${_uid}_$contentId');
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({'userId': _uid, 'contentId': contentId, 'createdAt': FieldValue.serverTimestamp()});
    }
  }

  Stream<bool> isLiked(String contentId) {
    if (_uid.isEmpty || contentId.isEmpty) return const Stream<bool>.empty();
    return _db.collection('content_likes').doc('${_uid}_$contentId').snapshots().map((s) => s.exists);
  }

  Future<void> addComment(String contentId, String text) async {
    final value = text.trim();
    if (_uid.isEmpty || contentId.isEmpty || value.isEmpty) return;
    await _db.collection('content_comments').add({
      'contentId': contentId,
      'userId': _uid,
      'text': value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> comments(String contentId) {
    return _db.collection('content_comments').where('contentId', isEqualTo: contentId).orderBy('createdAt', descending: false).snapshots();
  }
}
