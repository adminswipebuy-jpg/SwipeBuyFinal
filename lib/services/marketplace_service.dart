import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MarketplaceService {
  MarketplaceService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Stream<QuerySnapshot<Map<String, dynamic>>> publishedListings({String? category}) {
    Query<Map<String, dynamic>> q = _db
        .collection('listings')
        .where('status', isEqualTo: 'published');
    if (category != null && category != 'For You') {
      q = q.where('category', isEqualTo: category);
    }
    return q.snapshots();
  }

  Future<String> createListing({
    required String title,
    required String category,
    required String location,
    required String price,
    String? videoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Authentication required.');
    if (title.trim().length < 3) throw ArgumentError('Title is too short.');

    final ref = await _db.collection('listings').add({
      'ownerId': user.uid,
      'title': title.trim(),
      'seller': user.displayName?.trim().isNotEmpty == true ? user.displayName!.trim() : 'SwipeBuy Seller',
      'category': category,
      'location': location.trim(),
      'price': price.trim(),
      'videoUrl': videoUrl ?? '',
      'status': 'pending_review',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<String> submitJobApplication({
    required String listingId,
    required String businessId,
    String candidateNote = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Authentication required.');
    final ref = await _db.collection('applications').add({
      'listingId': listingId,
      'businessId': businessId,
      'applicantId': user.uid,
      'candidateNote': candidateNote.trim(),
      'status': 'submitted',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
