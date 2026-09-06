
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_service.dart';

class TransactionFlowService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final PaymentService payments = PaymentService();

  String get uid => _auth.currentUser!.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> myOrders() {
    return _db.collection('orders')
      .where('customerId', isEqualTo: uid)
      .orderBy('createdAt', descending: true).snapshots();
  }

  Future<CheckoutSession> payForOrder({
    required String orderId,
    required String provider,
  }) async {
    final key = '${uid}_$orderId';
    return payments.createCheckout(
      orderId: orderId,
      provider: provider,
      idempotencyKey: key,
    );
  }

  Future<Map<dynamic, dynamic>> checkPayment(String sessionId) {
    return payments.verifyPayment(sessionId: sessionId);
  }
}
