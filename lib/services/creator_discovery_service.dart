import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'social_service.dart';

class CreatorDiscoveryItem {
  final String id;
  final Map<String, dynamic> data;
  const CreatorDiscoveryItem({required this.id, required this.data});

  String get name => (data['displayName'] ?? data['name'] ?? data['username'] ?? 'SwipeBuy Creator').toString();
  String get bio => (data['bio'] ?? 'Sharing useful things on SwipeBuy.').toString();
  String get category => (data['creatorCategory'] ?? data['category'] ?? 'All').toString();
  String get avatarUrl => (data['avatarUrl'] ?? data['photoUrl'] ?? '').toString();
  bool get verified => data['verified'] == true;
  int get followers => (data['followersCount'] as num?)?.toInt() ?? 0;
}

class CreatorDiscoveryService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final SocialService _social = SocialService();

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<List<CreatorDiscoveryItem>> discover({String query = '', String category = 'All'}) {
    return _db.collection('users').limit(80).snapshots().map((snap) {
      final q = query.trim().toLowerCase();
      final items = snap.docs
          .where((d) => d.id != uid)
          .map((d) => CreatorDiscoveryItem(id: d.id, data: d.data()))
          .where((item) {
            final creatorMode = item.data['creatorMode'] == true ||
                item.data['profileMode']?.toString().toLowerCase() == 'creator' ||
                item.data['accountType']?.toString().toLowerCase() == 'creator';
            if (!creatorMode) return false;
            if (category != 'All' && item.category.toLowerCase() != category.toLowerCase()) return false;
            if (q.isEmpty) return true;
            return '${item.name} ${item.data['username'] ?? ''} ${item.bio} ${item.category}'.toLowerCase().contains(q);
          })
          .toList();
      items.sort((a, b) => b.followers.compareTo(a.followers));
      return items;
    });
  }

  Stream<bool> isFollowing(String creatorId) => _social.isFollowing(creatorId);
  Future<void> toggleFollow(String creatorId) => _social.isFollowing(creatorId).first.then((following) => following ? _social.unfollowProvider(creatorId) : _social.followProvider(creatorId));
}
