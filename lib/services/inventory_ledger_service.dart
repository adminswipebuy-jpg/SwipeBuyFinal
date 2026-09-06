import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum InventoryMovementType { restock, sale, cancellation, returnItem, adjustment, transfer }

class InventoryLedgerService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String,dynamic>> get products =>
      _db.collection('users').doc(uid).collection('catalog');

  Future<void> recordMovement({
    required String productId,
    required int quantity,
    required InventoryMovementType type,
    required String locationId,
    String? referenceId,
    String? note,
  }) async {
    if (uid.isEmpty || quantity == 0) return;
    final ledger = products.doc(productId).collection('inventory_ledger').doc();
    await ledger.set({
      'quantity': quantity,
      'type': type.name,
      'locationId': locationId,
      'referenceId': referenceId,
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String,dynamic>>> movements(String productId) =>
      products.doc(productId).collection('inventory_ledger')
          .orderBy('createdAt', descending: true).limit(200).snapshots();

  Stream<QuerySnapshot<Map<String,dynamic>>> locations() =>
      _db.collection('users').doc(uid).collection('inventory_locations')
          .orderBy('name').snapshots();

  Future<void> saveLocation({
    required String id,
    required String name,
    required String address,
    required bool active,
  }) async {
    if (uid.isEmpty) return;
    await _db.collection('users').doc(uid).collection('inventory_locations').doc(id).set({
      'name': name.trim(),
      'address': address.trim(),
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
