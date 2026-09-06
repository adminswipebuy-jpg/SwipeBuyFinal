import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowingFeedService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> followingProviders() {
    if (uid.isEmpty) {
      return _db.collection('follows').where('followerId', isEqualTo: '__none__').snapshots();
    }
    return _db.collection('follows')
        .where('followerId', isEqualTo: uid)
        .snapshots();
  }

  Future<List<String>> getFollowingProviderIds() async {
    if (uid.isEmpty) return [];
    final snap = await _db.collection('follows')
        .where('followerId', isEqualTo: uid)
        .get();
    return snap.docs
        .map((d) => (d.data()['providerId'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toList();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchFollowingListings() async {
    final ids = await getFollowingProviderIds();
    if (ids.isEmpty) return [];

    final results = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (final id in ids) {
      final snap = await _db.collection('listings')
          .where('ownerId', isEqualTo: id)
          .where('status', isEqualTo: 'published')
          .limit(20)
          .get();
      results.addAll(snap.docs);
    }
    results.sort((a, b) {
      final at = a.data()['createdAt'];
      final bt = b.data()['createdAt'];
      if (at is Timestamp && bt is Timestamp) return bt.compareTo(at);
      return 0;
    });
    return results;
  }
}
