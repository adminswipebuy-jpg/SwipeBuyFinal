import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModerationService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Future<void> reportContent({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) async {
    if (uid.isEmpty) throw StateError('You must be signed in.');
    await _db.collection('reports').add({
      'reporterId': uid,
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason,
      'details': (details ?? '').trim(),
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> blockUser(String targetUid) async {
    if (uid.isEmpty || targetUid.isEmpty || targetUid == uid) return;
    await _db.collection('users').doc(uid).collection('blocks').doc(targetUid).set({
      'blockedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unblockUser(String targetUid) async {
    if (uid.isEmpty || targetUid.isEmpty) return;
    await _db.collection('users').doc(uid).collection('blocks').doc(targetUid).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> blockedUsers() {
    if (uid.isEmpty) {
      return const Stream.empty();
    }
    return _db.collection('users').doc(uid).collection('blocks').orderBy('blockedAt', descending: true).snapshots();
  }

  Future<void> saveSafetySettings({
    required bool sensitiveContentFilter,
    required bool messageRequests,
    required bool personalizedNotifications,
  }) async {
    if (uid.isEmpty) return;
    await _db.collection('users').doc(uid).collection('settings').doc('safety').set({
      'sensitiveContentFilter': sensitiveContentFilter,
      'messageRequests': messageRequests,
      'personalizedNotifications': personalizedNotifications,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
