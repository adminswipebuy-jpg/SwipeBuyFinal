
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> pendingListings() =>
      _db.collection('listings').where('status', isEqualTo: 'pending_review').snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> reports() =>
      _db.collection('reports').orderBy('createdAt', descending: true).limit(100).snapshots();

  Future<void> moderateListing(String id, String status) async {
    const allowed = {'published', 'rejected', 'suspended'};
    if (!allowed.contains(status)) throw Exception('Invalid moderation status');
    // Production: use an admin-only callable function. This client method
    // exists as a UI/service contract only.
    await _db.collection('listings').doc(id).update({
      'status': status,
      'moderatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resolveReport(String id, String resolution) async {
    await _db.collection('reports').doc(id).update({
      'status': 'resolved',
      'resolution': resolution.trim(),
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }
}
