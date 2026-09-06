import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReputationService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> providerReviews(String providerId) {
    return _db.collection('reviews')
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  Future<void> submitReview({
    required String providerId,
    required String orderId,
    required int rating,
    required String text,
  }) async {
    if (uid.isEmpty || providerId.isEmpty || orderId.isEmpty) return;
    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating must be between 1 and 5.');
    }
    final body = text.trim();
    if (body.length > 1000) {
      throw ArgumentError('Review is too long.');
    }

    await _db.collection('reviews').add({
      'providerId': providerId,
      'customerId': uid,
      'orderId': orderId,
      'rating': rating,
      'text': body,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> providerStats(String providerId) {
    return _db.collection('provider_stats').where('providerId', isEqualTo: providerId).limit(1).snapshots();
  }
}
