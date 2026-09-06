import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContentItem {
  final String id;
  final String title;
  final String creator;
  final String category;
  final String location;
  final String summary;
  final String actionLabel;
  final String contentType;
  final int likes;
  final int comments;
  final int shares;
  final bool verified;
  final String? imageUrl;
  final String? creatorId;

  const ContentItem({
    required this.id,
    required this.title,
    required this.creator,
    required this.category,
    required this.location,
    required this.summary,
    required this.actionLabel,
    required this.contentType,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.verified,
    this.imageUrl,
    this.creatorId,
  });

  factory ContentItem.fromMap(String id, Map<String, dynamic> data) {
    return ContentItem(
      id: id,
      title: (data['title'] ?? 'SwipeBuy story').toString(),
      creator: (data['creator'] ?? data['seller'] ?? 'SwipeBuy').toString(),
      category: (data['category'] ?? 'For You').toString(),
      location: (data['location'] ?? data['locationName'] ?? 'Worldwide').toString(),
      summary: (data['summary'] ?? data['description'] ?? '').toString(),
      actionLabel: (data['actionLabel'] ?? 'Open').toString(),
      contentType: (data['contentType'] ?? 'story').toString(),
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      comments: (data['comments'] as num?)?.toInt() ?? 0,
      shares: (data['shares'] as num?)?.toInt() ?? 0,
      verified: data['verified'] == true,
      imageUrl: (data['mediaUrl'] ?? data['imageUrl'])?.toString(),
      creatorId: data['creatorId']?.toString(),
    );
  }
}

class ContentFeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<ContentItem>> load({String? category, int limit = 30}) async {
    final requested = category?.trim();
    try {
      Query<Map<String, dynamic>> query = _db
          .collection('content_items')
          .where('status', isEqualTo: 'published')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (requested != null && requested.isNotEmpty && requested != 'For You') {
        query = query.where('category', isEqualTo: requested);
      }

      final snap = await query.get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) => ContentItem.fromMap(d.id, d.data())).toList();
      }
    } catch (_) {
      // Demo content keeps the app usable while production indexes/content
      // ingestion are being connected.
    }

    final fallback = demoContent;
    if (requested == null || requested.isEmpty || requested == 'For You') {
      return fallback.take(limit).toList();
    }
    final filtered = fallback.where((x) => x.category == requested).toList();
    return (filtered.isEmpty ? fallback.take(3).toList() : filtered).take(limit).toList();
  }

  Future<void> record(String contentId, String event, {double value = 1}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || contentId.isEmpty) return;
    await _db.collection('content_events').add({
      'contentId': contentId,
      'userId': uid,
      'event': event,
      'value': value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

const demoContent = <ContentItem>[
  ContentItem(id: 'demo-sports-1', title: 'Black Stars match highlights', creator: 'SwipeBuy Sports', category: 'Sports', location: 'Ghana', summary: 'Match moments, analysis and the latest football stories in one feed.', actionLabel: 'Watch Highlights', contentType: 'video', likes: 24500, comments: 1200, shares: 892, verified: true),
  ContentItem(id: 'demo-news-1', title: 'Ghana Today: top stories', creator: 'SwipeBuy News', category: 'News', location: 'Ghana', summary: 'Breaking stories across business, technology, culture and the world.', actionLabel: 'Read Full Story', contentType: 'news', likes: 21600, comments: 1400, shares: 1100, verified: true),
  ContentItem(id: 'demo-forex-1', title: 'USD/GHS market watch', creator: 'SwipeBuy Finance', category: 'Forex', location: 'Global', summary: 'Follow currency movements and learn how the market works.', actionLabel: 'Open Market', contentType: 'finance', likes: 14200, comments: 386, shares: 720, verified: true),
  ContentItem(id: 'demo-crypto-1', title: 'Crypto market update', creator: 'SwipeBuy Crypto', category: 'Crypto', location: 'Global', summary: 'Prices, market context and beginner-friendly crypto education.', actionLabel: 'View Market', contentType: 'finance', likes: 18700, comments: 921, shares: 1300, verified: true),
  ContentItem(id: 'demo-invest-1', title: 'Investing for beginners', creator: 'SwipeBuy Invest', category: 'Investment', location: 'Global', summary: 'Learn diversification, risk and long-term investing concepts.', actionLabel: 'Start Learning', contentType: 'education', likes: 9400, comments: 512, shares: 680, verified: true),
  ContentItem(id: 'demo-realestate-1', title: 'Property opportunities', creator: 'SwipeBuy Property', category: 'Real Estate', location: 'Ghana', summary: 'Discover homes, land, rentals and commercial opportunities.', actionLabel: 'Explore Property', contentType: 'property', likes: 6800, comments: 244, shares: 410, verified: true),
  ContentItem(id: 'demo-jobs-1', title: 'Driver needed in Wa', creator: 'Alhaji Transport', category: 'Jobs', location: 'Wa, Ghana', summary: 'Full-time opportunity with one-click application.', actionLabel: 'Apply Now', contentType: 'job', likes: 2100, comments: 32, shares: 89, verified: true),
  ContentItem(id: 'demo-edu-1', title: 'Online business masterclass', creator: 'SwipeBuy Academy', category: 'Education', location: 'Online', summary: 'Find a niche, build a brand, sell online and grow globally.', actionLabel: 'Enroll Now', contentType: 'course', likes: 6400, comments: 312, shares: 1200, verified: true),
  ContentItem(id: 'demo-fitness-1', title: '30-day fitness challenge', creator: 'SwipeBuy Fitness', category: 'Fitness', location: 'Online', summary: 'Simple routines designed to help beginners build consistency.', actionLabel: 'Start Workout', contentType: 'fitness', likes: 11300, comments: 607, shares: 900, verified: true),
  ContentItem(id: 'demo-shopping-1', title: 'New products worth discovering', creator: 'SwipeBuy Marketplace', category: 'Lifestyle', location: 'Worldwide', summary: 'Discover products and services through short, useful visual stories.', actionLabel: 'Shop Now', contentType: 'shopping', likes: 8200, comments: 342, shares: 1100, verified: true),
];
