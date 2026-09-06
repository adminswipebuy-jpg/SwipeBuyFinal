import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> notifications() {
    if (uid.isEmpty) {
      return _db.collection('notifications').where('userId', isEqualTo: '__none__').snapshots();
    }
    return _db.collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }

  Future<void> markRead(String notificationId) async {
    if (uid.isEmpty) return;
    final ref = _db.collection('notifications').doc(notificationId);
    final snap = await ref.get();
    if (snap.exists && snap.data()?['userId'] == uid) {
      await ref.update({'read': true});
    }
  }

  Future<void> registerDeviceToken(String token) async {
    if (uid.isEmpty || token.isEmpty) return;
    await _db.collection('users').doc(uid).collection('devices').doc(token).set({
      'token': token,
      'updatedAt': FieldValue.serverTimestamp(),
      'platform': 'mobile',
    });
  }
}
