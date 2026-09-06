import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatorPublishService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Future<String> createStory({
    required String mediaUrl,
    required String mediaType,
    required String caption,
    required String category,
    String privacy = 'public',
  }) async {
    if (uid.isEmpty) throw StateError('You must be signed in.');
    final user = _auth.currentUser!;
    final ref = _db.collection('stories').doc();
    await ref.set({
      'creatorId': uid,
      'creator': user.displayName?.trim().isNotEmpty == true ? user.displayName : 'SwipeBuy Creator',
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption.trim(),
      'category': category,
      'privacy': privacy,
      'status': 'published',
      'views': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
    });
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> activeStories({int limit = 50}) {
    return _db.collection('stories')
        .where('status', isEqualTo: 'published')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .limit(limit)
        .snapshots();
  }

  Future<void> incrementStoryView(String storyId) async {
    if (storyId.isEmpty) return;
    await _db.collection('stories').doc(storyId).update({'views': FieldValue.increment(1)});
  }

  Future<String> createLiveSession({
    required String title,
    required String category,
    String? coverUrl,
  }) async {
    if (uid.isEmpty) throw StateError('You must be signed in.');
    final user = _auth.currentUser!;
    final ref = _db.collection('live_sessions').doc();
    await ref.set({
      'creatorId': uid,
      'creator': user.displayName?.trim().isNotEmpty == true ? user.displayName : 'SwipeBuy Creator',
      'title': title.trim(),
      'category': category,
      'coverUrl': coverUrl,
      'status': 'live',
      'viewerCount': 0,
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'startedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> endLiveSession(String sessionId) async {
    if (uid.isEmpty || sessionId.isEmpty) return;
    await _db.collection('live_sessions').doc(sessionId).update({
      'status': 'ended',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> activeLives({int limit = 20}) {
    return _db.collection('live_sessions')
        .where('status', isEqualTo: 'live')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }
}
