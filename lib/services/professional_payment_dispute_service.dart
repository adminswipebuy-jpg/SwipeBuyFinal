import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ProfessionalPaymentDisputeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => AuthService.currentUser?.uid;

  Stream<List<Map<String, dynamic>>> streamMyRequests() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('professional_financial_requests').where('clientId', isEqualTo: uid).snapshots().map((s) {
      final rows = s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      rows.sort((a, b) => ((b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0).compareTo((a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0));
      return rows;
    });
  }

  Future<void> createEscrowRequest({required String bookingId, required String providerName, required String amount, required String currency}) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('professional_financial_requests').add({
      'clientId': uid,
      'bookingId': bookingId,
      'providerName': providerName,
      'amount': amount.trim(),
      'currency': currency.trim().toUpperCase(),
      'kind': 'escrow_funding',
      'status': 'pending_backend_confirmation',
      'paymentStatus': 'not_started',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestPayoutRelease({required String bookingId}) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('professional_financial_requests').add({
      'clientId': uid,
      'bookingId': bookingId,
      'kind': 'payout_release',
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> openDispute({required String bookingId, required String reason, required String details}) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('professional_disputes').add({
      'clientId': uid,
      'bookingId': bookingId,
      'reason': reason,
      'details': details.trim(),
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
