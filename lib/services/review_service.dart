
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> submitReview({
    required String listingId,
    required String businessId,
    required int rating,
    required String comment,
    required String orderId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    if (rating < 1 || rating > 5) throw Exception('Rating must be 1-5');
    await _db.collection('reviews').add({
      'listingId': listingId,
      'businessId': businessId,
      'customerId': uid,
      'orderId': orderId,
      'rating': rating,
      'comment': comment.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
