import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SocialFeedV2Item {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String ownerId;
  final Timestamp? createdAt;
  final Map<String, dynamic> data;

  const SocialFeedV2Item({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.ownerId,
    required this.createdAt,
    required this.data,
  });
}

class SocialFeedV2Service {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Future<List<String>> followingIds() async {
    if (uid.isEmpty) return [];
    final snap = await _db.collection('follows').where('followerId', isEqualTo: uid).limit(100).get();
    return snap.docs
        .map((d) => (d.data()['providerId'] ?? '').toString())
        .where((id) => id.isNotEmpty && id != uid)
        .toList();
  }

  Future<List<SocialFeedV2Item>> loadPulse({int perProvider = 8}) async {
    final ids = await followingIds();
    if (ids.isEmpty) return [];
    final items = <SocialFeedV2Item>[];

    for (final ownerId in ids) {
      final content = await _db.collection('content')
          .where('creatorId', isEqualTo: ownerId)
          .limit(perProvider)
          .get();
      for (final doc in content.docs) {
        final d = doc.data();
        items.add(SocialFeedV2Item(
          id: doc.id,
          type: 'content',
          title: (d['title'] ?? 'New post').toString(),
          subtitle: (d['summary'] ?? d['description'] ?? 'New update from someone you follow').toString(),
          ownerId: ownerId,
          createdAt: d['createdAt'] is Timestamp ? d['createdAt'] as Timestamp : null,
          data: d,
        ));
      }

      final listings = await _db.collection('listings')
          .where('ownerId', isEqualTo: ownerId)
          .where('status', isEqualTo: 'published')
          .limit(perProvider)
          .get();
      for (final doc in listings.docs) {
        final d = doc.data();
        items.add(SocialFeedV2Item(
          id: doc.id,
          type: 'listing',
          title: (d['title'] ?? 'New listing').toString(),
          subtitle: (d['description'] ?? d['locationName'] ?? 'New opportunity from a provider you follow').toString(),
          ownerId: ownerId,
          createdAt: d['createdAt'] is Timestamp ? d['createdAt'] as Timestamp : null,
          data: d,
        ));
      }
    }

    items.sort((a, b) {
      final at = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bt = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return bt.compareTo(at);
    });
    return items.take(80).toList();
  }
}
