import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiMemoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _memories(String uid) => _db.collection('users').doc(uid).collection('ai_memory');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMemories() {
    final id = uid;
    if (id == null) return const Stream.empty();
    return _memories(id).orderBy('updatedAt', descending: true).limit(50).snapshots();
  }

  Future<void> saveMemory({required String title, required String value, String category = 'Preference'}) async {
    final id = uid;
    if (id == null) throw StateError('Sign in to manage AI memory.');
    await _memories(id).add({
      'userId': id,
      'title': title.trim(),
      'value': value.trim(),
      'category': category,
      'enabled': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setEnabled(String memoryId, bool enabled) async {
    final id = uid;
    if (id == null) throw StateError('Sign in to manage AI memory.');
    await _memories(id).doc(memoryId).update({'enabled': enabled, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> deleteMemory(String memoryId) async {
    final id = uid;
    if (id == null) throw StateError('Sign in to manage AI memory.');
    await _memories(id).doc(memoryId).delete();
  }
}
