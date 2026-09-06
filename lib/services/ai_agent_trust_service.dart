import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiAgentTrustService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamReviews(String agentId) {
    return _db.collection('ai_agent_reviews')
        .where('agentId', isEqualTo: agentId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyReports() {
    final userId = uid;
    if (userId == null) return const Stream.empty();
    return _db.collection('ai_agent_reports')
        .where('reporterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  Future<void> submitReview({
    required String agentId,
    required int rating,
    required String comment,
  }) async {
    final userId = uid;
    if (userId == null) throw StateError('Sign in to review an AI agent.');
    if (rating < 1 || rating > 5) throw ArgumentError('Rating must be between 1 and 5.');
    final text = comment.trim();
    if (text.length < 3) throw ArgumentError('Please add a little more detail to your review.');
    await _db.collection('ai_agent_reviews').add({
      'agentId': agentId,
      'reviewerId': userId,
      'rating': rating,
      'comment': text,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> reportAgent({
    required String agentId,
    required String reason,
    required String details,
  }) async {
    final userId = uid;
    if (userId == null) throw StateError('Sign in to report an AI agent.');
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) throw ArgumentError('Choose a report reason.');
    await _db.collection('ai_agent_reports').add({
      'agentId': agentId,
      'reporterId': userId,
      'reason': cleanReason,
      'details': details.trim(),
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> flagInstalledAgent({required String agentId, required String signal}) async {
    final userId = uid;
    if (userId == null) throw StateError('Sign in required.');
    await _db.collection('users').doc(userId).collection('agent_safety_signals').doc(agentId).set({
      'agentId': agentId,
      'signal': signal,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
