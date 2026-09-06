import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlobalLogisticsService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> myShipments() {
    if (uid.isEmpty) {
      return _db.collection('shipments').where('customerId', isEqualTo: '__none__').snapshots();
    }
    return _db.collection('shipments')
        .where('customerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> shipment(String shipmentId) =>
      _db.collection('shipments').doc(shipmentId).snapshots();

  Future<void> requestCrossBorderQuote({
    required String orderId,
    required String destinationCountry,
    required String serviceLevel,
  }) async {
    if (uid.isEmpty) return;
    await _db.collection('logisticsQuoteRequests').add({
      'customerId': uid,
      'orderId': orderId,
      'destinationCountry': destinationCountry,
      'serviceLevel': serviceLevel,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestTrackingRefresh(String shipmentId) async {
    if (uid.isEmpty) return;
    await _db.collection('shipmentTrackingRequests').add({
      'customerId': uid,
      'shipmentId': shipmentId,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
