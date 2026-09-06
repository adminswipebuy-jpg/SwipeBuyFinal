import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class GlobalIdentityVerificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>?> watchMine() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _db.collection('identity_verification_requests').doc(uid).snapshots().map((d) => d.exists ? d.data() : null);
  }

  Future<void> submit({required String legalName, required String country, required String entityType, required bool business, required bool professional}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null || legalName.trim().isEmpty) return;
    await _db.collection('identity_verification_requests').doc(uid).set({
      'ownerId': uid,
      'legalName': legalName.trim(),
      'country': country.trim(),
      'entityType': entityType,
      'business': business,
      'professional': professional,
      'status': 'pending_backend_review',
      'submittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> requestRecheck() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('identity_verification_requests').doc(uid).set({
      'status': 'recheck_requested',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
