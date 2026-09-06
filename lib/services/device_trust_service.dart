import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Backend-first device/account security control plane.
/// The client only records trusted-device/recovery requests; enforcement is server-side.
class DeviceTrustService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> watchDevices() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return Stream.value(const []);
    return _db.collection('trusted_devices').where('ownerId', isEqualTo: uid).snapshots().map(
      (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    );
  }

  Future<void> requestDeviceTrust({required String deviceLabel}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    final label = deviceLabel.trim();
    if (label.isEmpty) throw Exception('Device label required');
    await _db.collection('device_trust_requests').add({
      'ownerId': uid,
      'deviceLabel': label,
      'status': 'pending_backend_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestSignOutAllOtherDevices() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    await _db.collection('device_security_actions').add({
      'ownerId': uid,
      'action': 'sign_out_all_other_devices',
      'status': 'pending_backend_execution',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestAccountRecoveryReview({required String reason}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    final detail = reason.trim();
    if (detail.isEmpty) throw Exception('Recovery reason required');
    await _db.collection('account_recovery_requests').add({
      'ownerId': uid,
      'reason': detail,
      'status': 'pending_backend_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
