import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Backend-ready CRM layer. Customer insights, exports and outreach should be
/// permission-checked server-side before production use.
class BusinessCrmService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> customers() {
    if (uid.isEmpty) return const Stream.empty();
    return _db.collection('businessCustomers').where('businessId', isEqualTo: uid).limit(200).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> interactions() {
    if (uid.isEmpty) return const Stream.empty();
    return _db.collection('businessInteractions').where('businessId', isEqualTo: uid).limit(200).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> segments() {
    if (uid.isEmpty) return const Stream.empty();
    return _db.collection('businessCustomerSegments').where('businessId', isEqualTo: uid).limit(100).snapshots();
  }

  Future<void> createSegment({required String name, required String rule}) async {
    if (uid.isEmpty || name.trim().isEmpty) return;
    await _db.collection('businessCustomerSegments').add({
      'businessId': uid,
      'name': name.trim(),
      'rule': rule.trim(),
      'status': 'draft',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> queueOutreach({required String channel, required String segmentId, required String message}) async {
    if (uid.isEmpty || message.trim().isEmpty) return;
    await _db.collection('businessOutreachRequests').add({
      'businessId': uid,
      'channel': channel,
      'segmentId': segmentId,
      'message': message.trim(),
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestInsightsRefresh() async {
    if (uid.isEmpty) return;
    await _db.collection('businessCrmInsightRefreshRequests').add({
      'businessId': uid,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
