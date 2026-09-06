import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiAgentPlatformService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamInstalledAgents() {
    final userId = uid;
    if (userId == null) return const Stream.empty();
    return _db.collection('users').doc(userId).collection('installed_agents').orderBy('installedAt', descending: true).limit(50).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyAgents() {
    final userId = uid;
    if (userId == null) return const Stream.empty();
    return _db.collection('ai_agent_marketplace').where('ownerId', isEqualTo: userId).limit(50).snapshots();
  }

  Future<void> createUsageEvent({required String agentId, required String action}) async {
    final userId = uid;
    if (userId == null) return;
    await _db.collection('users').doc(userId).collection('ai_agent_events').add({
      'agentId': agentId,
      'action': action,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
