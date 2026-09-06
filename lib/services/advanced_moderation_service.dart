import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Client control plane only. Automated moderation scores and enforcement
/// decisions must be produced and enforced by trusted backend systems.
class AdvancedModerationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitSafetySignal({
    required String targetId,
    required String targetType,
    required String signal,
    String details = '',
  }) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    if (targetId.trim().isEmpty || targetType.trim().isEmpty || signal.trim().isEmpty) {
      throw Exception('Target and signal are required');
    }
    await _db.collection('automated_safety_signals').add({
      'reporterId': uid,
      'targetId': targetId.trim(),
      'targetType': targetType.trim(),
      'signal': signal.trim(),
      'details': details.trim(),
      'status': 'pending_backend_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestReview({required String targetId, required String reason}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    await _db.collection('safety_review_requests').add({
      'requesterId': uid,
      'targetId': targetId.trim(),
      'reason': reason.trim(),
      'status': 'pending_backend_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
