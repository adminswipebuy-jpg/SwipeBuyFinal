import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderTrackingService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> customerOrders() {
    if (uid.isEmpty) {
      return _db.collection('orders').where('customerId', isEqualTo: '__none__').snapshots();
    }
    return _db.collection('orders')
        .where('customerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> order(String orderId) {
    return _db.collection('orders').doc(orderId).snapshots();
  }

  String statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Order received';
      case 'payment_pending': return 'Payment processing';
      case 'confirmed': return 'Confirmed';
      case 'preparing': return 'Preparing';
      case 'ready': return 'Ready';
      case 'picked_up': return 'Picked up';
      case 'out_for_delivery': return 'Out for delivery';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      case 'refunded': return 'Refunded';
      default: return status.replaceAll('_', ' ');
    }
  }
}
