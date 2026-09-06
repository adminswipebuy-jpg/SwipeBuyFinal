import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContentAnalyticsService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> record(String contentId, String event, {double value = 1}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || contentId.isEmpty) return;
    await _db.collection('content_events').add({
      'contentId': contentId,
      'userId': uid,
      'event': event,
      'value': value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
