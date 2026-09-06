import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Engagement actions for the social/content graph.
/// Client writes are event-oriented; production counters should be aggregated by trusted backend jobs.
class ContentEngagementService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Future<void> recordView(String contentId, {int seconds = 0}) async {
    if (uid.isEmpty || contentId.isEmpty) return;
    await _db.collection('content_engagement_events').add({
      'contentId': contentId,
      'userId': uid,
      'eventType': 'view',
      'seconds': seconds.clamp(0, 86400),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleSave(String contentId) async {
    if (uid.isEmpty || contentId.isEmpty) return;
    final ref = _db.collection('content_saves').doc('${uid}_$contentId');
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
      return;
    }
    await ref.set({
      'userId': uid,
      'contentId': contentId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<bool> isSaved(String contentId) {
    if (uid.isEmpty || contentId.isEmpty) return const Stream<bool>.empty();
    return _db.collection('content_saves').doc('${uid}_$contentId').snapshots().map((s) => s.exists);
  }

  Future<void> recordShare(String contentId) async {
    if (uid.isEmpty || contentId.isEmpty) return;
    await _db.collection('content_engagement_events').add({
      'contentId': contentId,
      'userId': uid,
      'eventType': 'share',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> reportContent(String contentId, String reason) async {
    final value = reason.trim();
    if (uid.isEmpty || contentId.isEmpty || value.isEmpty) return;
    await _db.collection('content_reports').add({
      'contentId': contentId,
      'reporterId': uid,
      'reason': value,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
