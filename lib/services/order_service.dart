import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  static final _db = FirebaseFirestore.instance;

  static Future<String> createOrder({
    required String listingId,
    required String businessId,
    required String actionType,
    required String amountText,
    String note = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('You must be signed in.');

    final ref = await _db.collection('orders').add({
      'customerId': user.uid,
      'businessId': businessId,
      'listingId': listingId,
      'actionType': actionType,
      'amountText': amountText,
      'customerNote': note,
      'status': 'pending',
      'paymentStatus': 'unpaid',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  static Future<String> submitApplication({
    required String listingId,
    required String businessId,
    required String note,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('You must be signed in.');

    final ref = await _db.collection('applications').add({
      'applicantId': user.uid,
      'businessId': businessId,
      'listingId': listingId,
      'candidateNote': note,
      'status': 'submitted',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
