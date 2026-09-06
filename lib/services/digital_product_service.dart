import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Digital products marketplace control plane.
/// File delivery, payment authorization, licensing, entitlements and refunds
/// must be enforced by trusted backend services. The client only creates requests.
class DigitalProductService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> publishedProducts() =>
      _db.collection('digital_products')
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .limit(60)
        .snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> myLibrary() {
    if (uid.isEmpty) return const Stream.empty();
    return _db.collection('digital_entitlements')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(60)
      .snapshots();
  }

  Future<void> requestPurchase({required String productId}) async {
    if (uid.isEmpty || productId.isEmpty) return;
    await _db.collection('digital_purchase_requests').add({
      'userId': uid,
      'productId': productId,
      'status': 'pending_payment',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestDownload({required String entitlementId}) async {
    if (uid.isEmpty || entitlementId.isEmpty) return;
    await _db.collection('digital_download_requests').add({
      'userId': uid,
      'entitlementId': entitlementId,
      'status': 'pending_authorization',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> publishProduct({
    required String title,
    required String description,
    required String category,
    required String priceLabel,
    required String fileType,
  }) async {
    if (uid.isEmpty || title.trim().isEmpty) return;
    await _db.collection('digital_products').add({
      'creatorId': uid,
      'title': title.trim(),
      'description': description.trim(),
      'category': category.trim().isEmpty ? 'Digital Product' : category.trim(),
      'priceLabel': priceLabel.trim().isEmpty ? 'Price set at checkout' : priceLabel.trim(),
      'fileType': fileType.trim().isEmpty ? 'Digital download' : fileType.trim(),
      'status': 'pending_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
