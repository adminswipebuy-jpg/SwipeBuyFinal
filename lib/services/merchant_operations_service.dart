import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Backend-ready merchant operations layer. Critical inventory, fulfillment,
/// refunds and payouts should ultimately be validated by trusted backend code.
class MerchantOperationsService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> inventory() {
    if (uid.isEmpty) return const Stream.empty();
    return _db.collection('users').doc(uid).collection('catalog')
        .orderBy('updatedAt', descending: true).limit(200).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fulfillmentTasks() {
    if (uid.isEmpty) return const Stream.empty();
    return _db.collection('merchantFulfillmentTasks')
        .where('merchantId', isEqualTo: uid).limit(100).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> returnRequests() {
    if (uid.isEmpty) return const Stream.empty();
    return _db.collection('returns')
        .where('sellerId', isEqualTo: uid).limit(100).snapshots();
  }

  Future<void> createFulfillmentTask({
    required String orderId,
    required String action,
    required String priority,
  }) async {
    if (uid.isEmpty || orderId.trim().isEmpty) return;
    await _db.collection('merchantFulfillmentTasks').add({
      'merchantId': uid,
      'orderId': orderId.trim(),
      'action': action,
      'priority': priority,
      'status': 'queued',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestOperationalSync() async {
    if (uid.isEmpty) return;
    await _db.collection('merchantOpsSyncRequests').add({
      'merchantId': uid,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    if (uid.isEmpty || taskId.isEmpty) return;
    await _db.collection('merchantFulfillmentTasks').doc(taskId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitTeamInvite({required String email, required String role}) async {
    if (uid.isEmpty || !email.contains('@')) return;
    await _db.collection('merchantTeamInvites').add({
      'merchantId': uid,
      'email': email.trim().toLowerCase(),
      'role': role,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
