import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MarketplaceV2Service {
  MarketplaceV2Service({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser?.uid ?? (throw StateError('Authentication required.'));

  CollectionReference<Map<String, dynamic>> get _wishlist =>
      _db.collection('users').doc(_uid).collection('wishlist');

  CollectionReference<Map<String, dynamic>> get _comparisons =>
      _db.collection('users').doc(_uid).collection('comparisons');

  Stream<QuerySnapshot<Map<String, dynamic>>> wishlistStream() => _wishlist.orderBy('createdAt', descending: true).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> comparisonStream() => _comparisons.orderBy('createdAt', descending: true).snapshots();

  Future<void> setWishlist({required String productId, required String businessId, required String title, required String price}) async {
    await _wishlist.doc('${businessId}_$productId').set({
      'productId': productId,
      'businessId': businessId,
      'title': title,
      'price': price,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeWishlist(String businessId, String productId) async {
    await _wishlist.doc('${businessId}_$productId').delete();
  }

  Future<void> addToComparison({required String productId, required String businessId, required String title, required String price}) async {
    if ((await _comparisons.get()).docs.length >= 4) {
      throw StateError('Comparison is limited to 4 products.');
    }
    await _comparisons.doc('${businessId}_$productId').set({
      'productId': productId,
      'businessId': businessId,
      'title': title,
      'price': price,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> clearComparison() async {
    final batch = _db.batch();
    final snap = await _comparisons.get();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<String> submitReturn({required String orderId, required String reason, String note = ''}) async {
    final ref = await _db.collection('returns').add({
      'orderId': orderId,
      'requesterId': _uid,
      'reason': reason,
      'note': note.trim(),
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> createCouponClaim({required String code, required String listingId}) async {
    await _db.collection('couponClaims').add({
      'userId': _uid,
      'code': code.trim().toUpperCase(),
      'listingId': listingId,
      'status': 'claimed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
