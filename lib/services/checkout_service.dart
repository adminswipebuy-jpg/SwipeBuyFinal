import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Backend-first checkout contract. This creates a checkout request only;
/// payment confirmation and order finalization must happen in a trusted backend.
class CheckoutService {
  CheckoutService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Future<String> createCheckoutRequest({
    required String productId,
    required String businessId,
    required String title,
    required String amountText,
    required String deliveryMethod,
    required String deliveryAddress,
    String couponCode = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('You must be signed in.');

    final ref = await _db.collection('checkoutSessions').add({
      'customerId': user.uid,
      'productId': productId,
      'businessId': businessId,
      'title': title,
      'amountText': amountText,
      'deliveryMethod': deliveryMethod,
      'deliveryAddress': deliveryAddress.trim(),
      'couponCode': couponCode.trim().toUpperCase(),
      'status': 'awaiting_payment',
      'paymentStatus': 'unpaid',
      'buyerProtection': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
