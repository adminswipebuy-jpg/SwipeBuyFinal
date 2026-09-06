import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Backend-first age assurance and family safety control plane.
/// The client records requests and preferences; trusted backend services must
/// perform age checks, enforce restrictions, and protect minor accounts.
class AgeSafetyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>?> watchMine() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _db.collection('age_safety_profiles').doc(uid).snapshots().map(
      (d) => d.exists ? d.data() : null,
    );
  }

  Future<void> requestAgeAssuranceReview({required String reason}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    await _db.collection('age_assurance_requests').add({
      'ownerId': uid,
      'reason': reason.trim().isEmpty ? 'user_requested' : reason.trim(),
      'status': 'pending_backend_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveSafetyPreferences({
    required bool restrictedContent,
    required bool discoverability,
    required bool directMessages,
  }) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    await _db.collection('age_safety_preferences').doc(uid).set({
      'restrictedContent': restrictedContent,
      'discoverability': discoverability,
      'directMessages': directMessages,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> requestFamilyLink({required String reason}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception('Sign in required');
    await _db.collection('family_safety_requests').add({
      'ownerId': uid,
      'reason': reason.trim().isEmpty ? 'family_link_requested' : reason.trim(),
      'status': 'pending_backend_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
