import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryManagementService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String,dynamic>> get catalog =>
      _db.collection('users').doc(uid).collection('catalog');

  Future<void> setStock({
    required String productId,
    required int stock,
    int lowStockThreshold = 5,
  }) async {
    if (uid.isEmpty || stock < 0) return;
    await catalog.doc(productId).update({
      'stock': stock,
      'lowStockThreshold': lowStockThreshold,
      'lowStock': stock <= lowStockThreshold,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> bulkSetActive(List<String> productIds, bool active) async {
    if (uid.isEmpty || productIds.isEmpty) return;
    final batch = _db.batch();
    for (final id in productIds) {
      batch.update(catalog.doc(id), {
        'active': active,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  bool isLowStock(Map<String,dynamic> data) {
    final stock=(data['stock'] as num?)?.toInt() ?? 0;
    final threshold=(data['lowStockThreshold'] as num?)?.toInt() ?? 5;
    return stock <= threshold;
  }

  bool hasSku(Map<String,dynamic> data) =>
      (data['sku']?.toString().trim().isNotEmpty ?? false);
}
