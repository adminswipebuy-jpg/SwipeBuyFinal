import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsService {
  final FirebaseFirestore db;
  AnalyticsService([FirebaseFirestore? firestore]) : db = firestore ?? FirebaseFirestore.instance;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> contentEvents() {
    final id = uid;
    if (id == null) return const Stream.empty();
    return db.collection('content_events').where('ownerId', isEqualTo: id).limit(500).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> orders() {
    final id = uid;
    if (id == null) return const Stream.empty();
    return db.collection('orders').where('businessId', isEqualTo: id).limit(300).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> creatorEarnings() {
    final id = uid;
    if (id == null) return const Stream.empty();
    return db.collection('creator_earnings').where('creatorId', isEqualTo: id).limit(300).snapshots();
  }

  Map<String, num> summarizeEvents(Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    num views = 0, likes = 0, comments = 0, shares = 0, saves = 0, watchSeconds = 0;
    for (final doc in docs) {
      final d = doc.data();
      final type = (d['eventType'] ?? d['type'] ?? '').toString().toLowerCase();
      final value = d['value'] is num ? d['value'] as num : 1;
      if (type.contains('view') || type.contains('impression')) views += value;
      if (type.contains('like')) likes += value;
      if (type.contains('comment')) comments += value;
      if (type.contains('share')) shares += value;
      if (type.contains('save')) saves += value;
      if (type.contains('watch')) watchSeconds += value;
    }
    return {
      'views': views,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'saves': saves,
      'watchSeconds': watchSeconds,
    };
  }
}
