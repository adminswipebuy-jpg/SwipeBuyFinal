import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeliveryManagementService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> merchantOrders() {
    if (uid.isEmpty) {
      return _db.collection('orders').where('businessId', isEqualTo: '__none__').snapshots();
    }
    return _db.collection('orders')
        .where('businessId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> courierJobs() {
    if (uid.isEmpty) {
      return _db.collection('orders').where('courierId', isEqualTo: '__none__').snapshots();
    }
    return _db.collection('orders')
        .where('courierId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots();
  }

  String label(String status) => {
    'pending': 'New',
    'payment_pending': 'Payment pending',
    'confirmed': 'Confirmed',
    'preparing': 'Preparing',
    'ready': 'Ready for pickup',
    'picked_up': 'Picked up',
    'out_for_delivery': 'Out for delivery',
    'delivered': 'Delivered',
    'cancelled': 'Cancelled',
    'refunded': 'Refunded',
  }[status] ?? status.replaceAll('_', ' ');

  Future<void> requestCourierAssignment(String orderId) async {
    // UI/request foundation. Production assignment must be server-authoritative.
    await _db.collection('orders').doc(orderId).update({
      'deliveryAssignmentRequested': true,
      'deliveryAssignmentRequestedAt': FieldValue.serverTimestamp(),
    });
  }
}
