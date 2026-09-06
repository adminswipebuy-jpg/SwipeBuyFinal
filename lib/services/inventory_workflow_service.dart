import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryWorkflowService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String,dynamic>> get locations =>
      _db.collection('users').doc(uid).collection('inventory_locations');

  Future<void> createTransfer({
    required String productId,
    required String fromLocationId,
    required String toLocationId,
    required int quantity,
    String? note,
  }) async {
    if (uid.isEmpty || quantity <= 0 || fromLocationId == toLocationId) return;
    final ref = _db.collection('users').doc(uid).collection('inventory_transfers').doc();
    await ref.set({
      'productId': productId,
      'fromLocationId': fromLocationId,
      'toLocationId': toLocationId,
      'quantity': quantity,
      'note': note?.trim(),
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String,dynamic>>> transfers() =>
      _db.collection('users').doc(uid).collection('inventory_transfers')
          .orderBy('createdAt', descending: true).limit(100).snapshots();

  Future<void> acknowledgeLowStock(String productId, String locationId) async {
    if (uid.isEmpty) return;
    await _db.collection('users').doc(uid).collection('inventory_alerts')
        .doc('${productId}_$locationId').set({
      'productId': productId,
      'locationId': locationId,
      'acknowledgedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
