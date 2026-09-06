import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductVariant {
  final String id;
  final String name;
  final String sku;
  final int price;
  final int stock;
  final bool active;

  const ProductVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    required this.active,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'sku': sku.trim().toUpperCase(),
    'price': price,
    'stock': stock,
    'active': active,
  };
}

class ProductVariantService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> variants(String productId) {
    if (uid.isEmpty) {
      return _db.collection('users').doc('__none__').collection('catalog')
          .doc(productId).collection('variants').snapshots();
    }
    return _db.collection('users').doc(uid).collection('catalog')
        .doc(productId).collection('variants').snapshots();
  }

  Future<void> saveVariant(String productId, ProductVariant variant) async {
    if (uid.isEmpty) return;
    await _db.collection('users').doc(uid).collection('catalog')
        .doc(productId).collection('variants').doc(variant.id).set(variant.toMap());
  }
}
