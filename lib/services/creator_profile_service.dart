import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatorProfileService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Future<Map<String, dynamic>> getProfile(String creatorId) async {
    final snap = await _db.collection('users').doc(creatorId).get();
    final data = snap.data() ?? <String, dynamic>{};
    return {
      'displayName': data['displayName'] ?? data['name'] ?? 'SwipeBuy Creator',
      'bio': data['bio'] ?? 'Sharing useful things on SwipeBuy.',
      'avatarUrl': data['avatarUrl'] ?? data['photoUrl'],
      'verified': data['verified'] == true,
      'followers': (data['followersCount'] as num?)?.toInt() ?? 0,
      'following': (data['followingCount'] as num?)?.toInt() ?? 0,
      ...data,
    };
  }

  Future<int> followerCount(String creatorId) async {
    if (creatorId.isEmpty) return 0;
    final snap = await _db.collection('follows').where('providerId', isEqualTo: creatorId).count().get();
    return snap.count ?? 0;
  }

  Future<int> followingCount(String creatorId) async {
    if (creatorId.isEmpty) return 0;
    final snap = await _db.collection('follows').where('followerId', isEqualTo: creatorId).count().get();
    return snap.count ?? 0;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> posts(String creatorId) {
    return _db
        .collection('content_items')
        .where('creatorId', isEqualTo: creatorId)
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }
}
