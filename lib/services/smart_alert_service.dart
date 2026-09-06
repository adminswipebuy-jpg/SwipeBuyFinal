import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SmartAlertService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> alerts({int limit = 80}) {
    if (uid.isEmpty) {
      return _db.collection('smart_alerts').where('userId', isEqualTo: '__none__').snapshots();
    }
    return _db.collection('smart_alerts')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> markRead(String alertId) async {
    if (uid.isEmpty) return;
    final ref = _db.collection('smart_alerts').doc(alertId);
    final snap = await ref.get();
    if (snap.exists && snap.data()?['userId'] == uid) {
      await ref.update({'read': true});
    }
  }

  Future<void> markAllRead() async {
    if (uid.isEmpty) return;
    final snap = await _db.collection('smart_alerts')
        .where('userId', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .limit(300)
        .get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<int> unreadCount() async {
    if (uid.isEmpty) return 0;
    final snap = await _db.collection('smart_alerts')
        .where('userId', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .limit(300)
        .get();
    return snap.docs.length;
  }
}
