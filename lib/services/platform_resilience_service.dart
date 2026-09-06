import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlatformResilienceService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> createRecoveryRequest(String type) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    await db.collection('platform_resilience_requests').add({
      'uid': uid,
      'type': type,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
