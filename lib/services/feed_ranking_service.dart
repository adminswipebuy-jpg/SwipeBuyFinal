import 'package:cloud_firestore/cloud_firestore.dart';

class FeedRankingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> load({
    required String mode,
    int limit = 40,
  }) async {
    try {
      final snap = await _db.collection('content_items')
          .where('status', isEqualTo: 'published')
          .limit(180)
          .get();
      final rows = snap.docs.map((d) => {...d.data(), '_id': d.id}).toList();
      rows.sort((a, b) => _score(b, mode).compareTo(_score(a, mode)));
      return rows.take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  double _score(Map<String, dynamic> d, String mode) {
    double n(String key) => (d[key] as num?)?.toDouble() ?? 0;
    final likes = n('likes');
    final shares = n('shares');
    final comments = n('comments');
    final views = n('views');
    final quality = n('qualityScore');
    final createdAt = d['createdAt'];
    var ageHours = 168.0;
    if (createdAt is Timestamp) {
      ageHours = DateTime.now().difference(createdAt.toDate()).inHours.clamp(0, 168).toDouble();
    }
    final freshness = (168 - ageHours) / 8;
    final engagement = (likes / 2500) + (shares / 1600) + (comments / 2500) + (views / 22000) + (quality * 4);
    switch (mode) {
      case 'Trending':
        return engagement * 1.7 + freshness;
      case 'Fresh':
        return freshness * 2.5 + engagement * .35;
      default:
        return engagement + freshness * .8;
    }
  }
}
