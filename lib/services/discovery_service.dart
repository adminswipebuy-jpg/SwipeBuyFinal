
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiscoveryService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> publishedFeed({
    String? category,
    String? location,
  }) {
    Query<Map<String, dynamic>> q = _db.collection('listings')
      .where('status', isEqualTo: 'published')
      .orderBy('createdAt', descending: true)
      .limit(50);

    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    if (location != null && location.isNotEmpty) {
      q = q.where('locationText', isEqualTo: location);
    }
    return q.snapshots();
  }

  Future<void> recordView(String listingId) async {
    final uid = _auth.currentUser?.uid;
    await _db.collection('listing_events').add({
      'listingId': listingId,
      'userId': uid,
      'event': 'view',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> recordAction(String listingId, String action) async {
    final uid = _auth.currentUser?.uid;
    await _db.collection('listing_events').add({
      'listingId': listingId,
      'userId': uid,
      'event': action,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
