import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Backend-first fraud/risk control plane. The client can record review requests,
/// but never decides whether a payment, seller, buyer, or account is trusted.
class FraudRiskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>?> watchMine() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _db.collection('risk_profiles').doc(uid).snapshots().map(
      (d) => d.exists ? d.data() : null,
    );
  }

  Future<void> requestAccountReview({String reason = 'user_requested'}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    await _db.collection('risk_review_requests').add({
      'ownerId': uid,
      'reason': reason,
      'status': 'pending_backend_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> reportTransaction({
    required String transactionId,
    required String reason,
  }) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    if (transactionId.trim().isEmpty) throw Exception('Transaction required');
    await _db.collection('risk_transaction_reports').add({
      'ownerId': uid,
      'transactionId': transactionId.trim(),
      'reason': reason.trim(),
      'status': 'pending_backend_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
