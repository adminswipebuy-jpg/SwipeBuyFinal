import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Backend-first MFA/passkey security control plane.
/// The client creates setup/change requests; authentication enforcement stays server-side.
class MfaSecurityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>?> watchSecurityProfile() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _db.collection('security_profiles').doc(uid).snapshots().map((d) => d.exists ? d.data() : null);
  }

  Future<void> requestMfaSetup({required String method}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    await _db.collection('mfa_setup_requests').add({
      'ownerId': uid,
      'method': method,
      'status': 'pending_backend_execution',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestPasskeyEnrollment() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    await _db.collection('passkey_enrollment_requests').add({
      'ownerId': uid,
      'status': 'pending_backend_execution',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestMfaDisable() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    await _db.collection('mfa_change_requests').add({
      'ownerId': uid,
      'action': 'disable_mfa',
      'status': 'pending_backend_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
