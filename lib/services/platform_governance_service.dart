import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Client-side control plane only. Final moderation, enforcement and audit decisions
/// must be made by trusted backend/admin systems.
class PlatformGovernanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitReport({required String targetId, required String targetType, required String reason}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    if (targetId.trim().isEmpty || targetType.trim().isEmpty || reason.trim().isEmpty) {
      throw Exception('Target and reason are required');
    }
    await _db.collection('platform_moderation_reports').add({
      'reporterId': uid,
      'targetId': targetId.trim(),
      'targetType': targetType.trim(),
      'reason': reason.trim(),
      'status': 'pending_backend_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestAppeal({required String caseId, required String reason}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    await _db.collection('platform_appeals').add({
      'requesterId': uid,
      'caseId': caseId.trim(),
      'reason': reason.trim(),
      'status': 'pending_backend_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
