
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> myListings() {
    return _db.collection('listings')
      .where('ownerId', isEqualTo: uid)
      .orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myOrders() {
    return _db.collection('orders')
      .where('businessId', isEqualTo: uid)
      .orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myApplications() {
    return _db.collection('applications')
      .where('businessId', isEqualTo: uid)
      .orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    const allowed = {
      'pending', 'payment_pending', 'paid', 'processing',
      'completed', 'cancelled', 'refunded'
    };
    if (!allowed.contains(status)) throw Exception('Invalid status');
    // Production: this transition should be performed by a trusted backend
    // after authorization/business ownership checks.
    await _db.collection('orders').doc(orderId).update({
      'businessStatus': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateApplicationStatus(String id, String status) async {
    const allowed = {'submitted', 'reviewing', 'accepted', 'rejected'};
    if (!allowed.contains(status)) throw Exception('Invalid status');
    await _db.collection('applications').doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
