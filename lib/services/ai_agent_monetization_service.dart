import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiAgentMonetizationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyAgentPurchases() {
    final userId = uid;
    if (userId == null) return const Stream.empty();
    return _db.collection('users').doc(userId).collection('agent_purchases').orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyAgentEarnings() {
    final userId = uid;
    if (userId == null) return const Stream.empty();
    return _db.collection('users').doc(userId).collection('agent_earnings').orderBy('createdAt', descending: true).snapshots();
  }

  Future<String> createPurchaseRequest({required String agentId, required double amount, required String currency}) async {
    final userId = uid;
    if (userId == null) throw StateError('Sign in to purchase an AI agent.');
    if (amount <= 0) throw ArgumentError('Amount must be greater than zero.');
    final ref = await _db.collection('agent_purchase_requests').add({
      'buyerId': userId,
      'agentId': agentId,
      'amount': amount,
      'currency': currency,
      'status': 'pending_payment',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> submitPayoutRequest({required double amount, required String method}) async {
    final userId = uid;
    if (userId == null) throw StateError('Sign in to request a payout.');
    if (amount <= 0) throw ArgumentError('Amount must be greater than zero.');
    await _db.collection('agent_payout_requests').add({
      'creatorId': userId,
      'amount': amount,
      'method': method,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
