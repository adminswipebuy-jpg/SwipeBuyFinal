import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataGovernanceService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  DataGovernanceService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  Future<void> saveConsent(String region, Map<String, bool> consents) async {
    if (_uid.isEmpty) throw StateError('Authentication required');
    await _db.collection('users').doc(_uid).collection('consent_records').add({
      'region': region,
      'consents': consents,
      'recordedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestComplianceReview({required String region, required String topic}) async {
    if (_uid.isEmpty) throw StateError('Authentication required');
    await _db.collection('privacy_compliance_requests').add({
      'uid': _uid,
      'region': region,
      'topic': topic,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
