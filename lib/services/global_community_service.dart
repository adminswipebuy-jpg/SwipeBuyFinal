import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Global creator/community platform foundation.
/// Trusted backend should enforce moderation, premium entitlements and creator privileges.
class GlobalCommunityService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> featuredCommunities() {
    return _db.collection('communities').where('status', isEqualTo: 'active').orderBy('memberCount', descending: true).limit(50).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> creatorHubs() {
    return _db.collection('creator_hubs').where('status', isEqualTo: 'active').limit(50).snapshots();
  }

  Future<void> followCommunity(String communityId) async {
    if (uid.isEmpty || communityId.isEmpty) return;
    await _db.collection('community_follows').doc('${uid}_$communityId').set({
      'userId': uid,
      'communityId': communityId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unfollowCommunity(String communityId) async {
    if (uid.isEmpty || communityId.isEmpty) return;
    await _db.collection('community_follows').doc('${uid}_$communityId').delete();
  }

  Stream<bool> isFollowingCommunity(String communityId) {
    if (uid.isEmpty) return Stream<bool>.value(false);
    return _db.collection('community_follows').doc('${uid}_$communityId').snapshots().map((d) => d.exists);
  }

  Future<void> createCreatorHub({required String name, required String description, required String category}) async {
    if (uid.isEmpty || name.trim().length < 3) return;
    await _db.collection('creator_hubs').add({
      'name': name.trim(),
      'description': description.trim(),
      'category': category.trim(),
      'ownerId': uid,
      'status': 'pending_review',
      'memberCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestModeratorReview({required String hubId, required String reason}) async {
    if (uid.isEmpty || hubId.isEmpty || reason.trim().isEmpty) return;
    await _db.collection('community_moderation_requests').add({
      'hubId': hubId,
      'requesterId': uid,
      'reason': reason.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
