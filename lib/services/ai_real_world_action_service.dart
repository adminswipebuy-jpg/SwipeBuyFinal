import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiRealWorldAction {
  final String type;
  final String title;
  final String description;
  final Map<String, dynamic> parameters;
  final bool requiresConfirmation;

  const AiRealWorldAction({
    required this.type,
    required this.title,
    required this.description,
    required this.parameters,
    this.requiresConfirmation = true,
  });
}

class AiRealWorldActionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  AiRealWorldAction buildAction(String prompt) {
    final text = prompt.trim().toLowerCase();
    if (RegExp(r'\b(buy|purchase|checkout)\b').hasMatch(text)) {
      return AiRealWorldAction(
        type: 'prepare_checkout',
        title: 'Prepare checkout',
        description: 'Find or prepare a product checkout. Payment is never completed automatically.',
        parameters: {'prompt': prompt},
      );
    }
    if (RegExp(r'\b(book|reserve)\b').hasMatch(text)) {
      return AiRealWorldAction(
        type: 'prepare_booking',
        title: 'Prepare booking',
        description: 'Prepare a booking handoff for your review before anything is confirmed.',
        parameters: {'prompt': prompt},
      );
    }
    if (RegExp(r'\b(apply|application)\b').hasMatch(text)) {
      return AiRealWorldAction(
        type: 'prepare_job_application',
        title: 'Prepare job application',
        description: 'Collect a matching job and prepare an application draft without submitting it.',
        parameters: {'prompt': prompt},
      );
    }
    if (RegExp(r'\b(message|contact|send)\b').hasMatch(text)) {
      return AiRealWorldAction(
        type: 'draft_message',
        title: 'Draft a message',
        description: 'Create a message draft for your review. Sending remains a user-confirmed action.',
        parameters: {'prompt': prompt},
      );
    }
    if (RegExp(r'\b(save|wishlist|watch)\b').hasMatch(text)) {
      return AiRealWorldAction(
        type: 'save_discovery',
        title: 'Save a discovery',
        description: 'Save a relevant item or alert target for later review.',
        parameters: {'prompt': prompt},
        requiresConfirmation: false,
      );
    }
    return AiRealWorldAction(
      type: 'prepare_discovery',
      title: 'Prepare discovery',
      description: 'Search SwipeBuy and stage useful next steps without committing to any transaction.',
      parameters: {'prompt': prompt},
    );
  }

  Future<String> createRequest(AiRealWorldAction action) async {
    final id = uid;
    if (id == null) throw StateError('Sign in to create an action request.');
    final ref = await _db.collection('ai_action_requests').add({
      'userId': id,
      'type': action.type,
      'title': action.title,
      'description': action.description,
      'parameters': action.parameters,
      'requiresConfirmation': action.requiresConfirmation,
      'status': 'staged',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> confirm(String requestId) async {
    await _db.collection('ai_action_requests').doc(requestId).update({
      'status': 'confirmed',
      'confirmedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancel(String requestId) async {
    await _db.collection('ai_action_requests').doc(requestId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamRequests() {
    final id = uid;
    if (id == null) return const Stream.empty();
    return _db.collection('ai_action_requests')
      .where('userId', isEqualTo: id)
      .orderBy('createdAt', descending: true)
      .limit(30)
      .snapshots();
  }
}
