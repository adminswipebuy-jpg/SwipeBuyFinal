import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiProactiveAssistantService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _alerts(String id) =>
      _db.collection('users').doc(id).collection('ai_proactive_alerts');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAlerts() {
    final id = uid;
    if (id == null) return const Stream.empty();
    return _alerts(id).orderBy('createdAt', descending: true).limit(40).snapshots();
  }

  Future<void> createAlert({
    required String title,
    required String type,
    String query = '',
    String category = '',
    String cadence = 'daily',
  }) async {
    final id = uid;
    if (id == null) return;
    await _alerts(id).add({
      'title': title.trim(),
      'type': type,
      'query': query.trim(),
      'category': category.trim(),
      'cadence': cadence,
      'status': 'active',
      'lastTriggeredAt': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setStatus(String alertId, String status) async {
    final id = uid;
    if (id == null) return;
    await _alerts(id).doc(alertId).update({'status': status});
  }

  Future<void> deleteAlert(String alertId) async {
    final id = uid;
    if (id == null) return;
    await _alerts(id).doc(alertId).delete();
  }
}
