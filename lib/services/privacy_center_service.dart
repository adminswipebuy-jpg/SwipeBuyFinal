import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class PrivacyCenterService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _uid => AuthService.currentUser?.uid ?? '';

  DocumentReference<Map<String, dynamic>> get _ref =>
      _db.collection('privacy_profiles').doc(_uid);

  Stream<Map<String, dynamic>?> watchProfile() {
    if (_uid.isEmpty) return const Stream.empty();
    return _ref.snapshots().map((doc) => doc.data());
  }

  Future<void> updateControl(String field, bool value) async {
    if (_uid.isEmpty) throw StateError('Sign in required.');
    await _ref.set({field: value, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  Future<void> requestDataExport() async {
    await _request('export');
  }

  Future<void> requestAccountDeletion() async {
    await _request('delete');
  }

  Future<void> requestPrivacyReview(String reason) async {
    await _request('privacy_review', extra: {'reason': reason});
  }

  Future<void> _request(String type, {Map<String, dynamic>? extra}) async {
    if (_uid.isEmpty) throw StateError('Sign in required.');
    await _db.collection('privacy_requests').add({
      'uid': _uid,
      'type': type,
      'status': 'pending_backend_review',
      'createdAt': FieldValue.serverTimestamp(),
      ...?extra,
    });
  }
}
