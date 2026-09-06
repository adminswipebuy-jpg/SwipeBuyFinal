import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiAutomationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _tasks => _db.collection('ai_automations');

  String? get uid => _auth.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamTasks() {
    final userId = uid;
    if (userId == null) return const Stream.empty();
    return _tasks.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> createTask({
    required String title,
    required String instruction,
    required String schedule,
    bool enabled = true,
  }) async {
    final userId = uid;
    if (userId == null) throw StateError('Sign in to create an AI automation.');
    await _tasks.add({
      'userId': userId,
      'title': title.trim(),
      'instruction': instruction.trim(),
      'schedule': schedule,
      'enabled': enabled,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setEnabled(String id, bool enabled) async {
    await _tasks.doc(id).update({
      'enabled': enabled,
      'status': enabled ? 'active' : 'paused',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTask(String id) => _tasks.doc(id).delete();
}
