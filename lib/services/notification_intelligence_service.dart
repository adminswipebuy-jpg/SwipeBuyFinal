import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class NotificationIntelligenceService {
  final FirebaseFirestore _db;
  NotificationIntelligenceService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> events() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('notification_events').where('userId', isEqualTo: uid).limit(100).snapshots();
  }

  Future<void> recordPreference(String channel, bool enabled) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('notification_preferences').doc(uid).set({
      channel: enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> requestDeliveryReview({String reason = 'notification_delivery'}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('notification_delivery_reviews').add({
      'userId': uid,
      'reason': reason,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
