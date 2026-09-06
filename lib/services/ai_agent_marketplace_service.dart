import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiAgentMarketplaceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAgents({String category = 'All'}) {
    Query<Map<String, dynamic>> q = _db.collection('ai_agent_marketplace').where('published', isEqualTo: true).limit(40);
    if (category != 'All') q = q.where('category', isEqualTo: category);
    return q.snapshots();
  }

  Future<void> installAgent(String agentId) async {
    final userId = uid;
    if (userId == null) throw StateError('Sign in to install an AI agent.');
    await _db.collection('users').doc(userId).collection('installed_agents').doc(agentId).set({
      'agentId': agentId,
      'installedAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('ai_agent_marketplace').doc(agentId).set({
      'installCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Future<void> saveAgent(String agentId) async {
    final userId = uid;
    if (userId == null) throw StateError('Sign in to save an AI agent.');
    await _db.collection('users').doc(userId).collection('saved_agents').doc(agentId).set({
      'agentId': agentId,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> publishAgent({required String title, required String description, required String category, required List<String> steps}) async {
    final userId = uid;
    if (userId == null) throw StateError('Sign in to publish an AI agent.');
    await _db.collection('ai_agent_marketplace').add({
      'ownerId': userId,
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'steps': steps,
      'published': true,
      'rating': 0.0,
      'reviewCount': 0,
      'installCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
