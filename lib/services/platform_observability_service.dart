import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlatformObservabilityService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> recordMetric({required String name, required double value, String unit = 'ms'}) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    await db.collection('observability_metrics').add({
      'uid': uid,
      'name': name,
      'value': value,
      'unit': unit,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createReviewRequest({required String type, required String details}) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    if (details.trim().isEmpty) throw ArgumentError('Details required');
    await db.collection('platform_observability_requests').add({
      'uid': uid,
      'type': type,
      'details': details.trim(),
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
