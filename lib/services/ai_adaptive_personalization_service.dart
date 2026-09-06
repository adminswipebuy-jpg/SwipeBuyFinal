import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiAdaptivePersonalizationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _signals(String id) =>
      _db.collection('users').doc(id).collection('ai_learning_signals');

  Future<void> recordSignal({required String type, String? category, String? itemId, double weight = 1}) async {
    final id = uid;
    if (id == null) return;
    await _signals(id).add({
      'type': type,
      'category': category,
      'itemId': itemId,
      'weight': weight,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamSignals() {
    final id = uid;
    if (id == null) return const Stream.empty();
    return _signals(id).orderBy('createdAt', descending: true).limit(40).snapshots();
  }

  Future<Map<String, double>> buildCategoryProfile() async {
    final id = uid;
    if (id == null) return {};
    final snap = await _signals(id).limit(200).get();
    final scores = <String, double>{};
    for (final doc in snap.docs) {
      final d = doc.data();
      final category = d['category']?.toString().trim();
      if (category == null || category.isEmpty) continue;
      final weight = (d['weight'] as num?)?.toDouble() ?? 1;
      scores[category] = (scores[category] ?? 0) + weight;
    }
    return scores;
  }
}
