import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SafetyOperationsService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  SafetyOperationsService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? 'anonymous';

  Future<void> submitIncident({
    required String category,
    required String description,
    String? relatedId,
    String severity = 'standard',
  }) async {
    if (_uid == 'anonymous') throw StateError('Authentication required');
    await _db.collection('safety_incidents').add({
      'userId': _uid,
      'category': category,
      'description': description.trim(),
      'relatedId': relatedId,
      'severity': severity,
      'status': 'submitted',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestSafetyReview({
    required String incidentId,
    String? additionalContext,
  }) async {
    if (_uid == 'anonymous') throw StateError('Authentication required');
    await _db.collection('safety_review_requests').add({
      'userId': _uid,
      'incidentId': incidentId,
      'additionalContext': additionalContext?.trim(),
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myIncidents() {
    if (_uid == 'anonymous') return const Stream.empty();
    return _db.collection('safety_incidents')
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
