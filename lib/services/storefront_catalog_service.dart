import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CatalogItem {
  final String id;
  final String title;
  final String description;
  final int price;
  final String currency;
  final int stock;
  final List<String> images;
  final List<String> variants;
  final bool active;

  const CatalogItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.stock,
    required this.images,
    required this.variants,
    required this.active,
  });

  bool get inStock => active && stock > 0;

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'price': price,
    'currency': currency,
    'stock': stock,
    'images': images,
    'variants': variants,
    'active': active,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

class StorefrontCatalogService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> storefrontItems(String businessId) {
    return _db.collection('users').doc(businessId).collection('catalog')
        .where('active', isEqualTo: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myItems() {
    if (uid.isEmpty) {
      return _db.collection('catalog').where('ownerId', isEqualTo: '__none__').snapshots();
    }
    return _db.collection('users').doc(uid).collection('catalog')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  Future<void> saveItem(CatalogItem item) async {
    if (uid.isEmpty) return;
    await _db.collection('users').doc(uid).collection('catalog').doc(item.id).set(
      item.toMap(),
      SetOptions(merge: true),
    );
  }

  Future<void> deleteItem(String itemId) async {
    if (uid.isEmpty) return;
    await _db.collection('users').doc(uid).collection('catalog').doc(itemId).update({
      'active': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
