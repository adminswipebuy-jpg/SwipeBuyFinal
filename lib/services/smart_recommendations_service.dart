import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SmartRecommendationItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String type;
  final double score;
  final String? imageUrl;

  const SmartRecommendationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.type,
    required this.score,
    this.imageUrl,
  });
}

class SmartRecommendationsService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Future<List<SmartRecommendationItem>> load({int limit = 20}) async {
    final profile = await _loadProfile();
    final interests = (profile?['interests'] as List?)
            ?.map((e) => e.toString().toLowerCase())
            .toSet() ??
        <String>{};
    final preferredCategory = profile?['preferredCategory']?.toString().toLowerCase();
    final preferredLocation = (profile?['location'] ?? profile?['preferredLocation'])?.toString().toLowerCase();

    final listingSnap = await _db
        .collection('listings')
        .where('status', isEqualTo: 'published')
        .limit(100)
        .get();

    final rows = <SmartRecommendationItem>[];
    for (final doc in listingSnap.docs) {
      final data = doc.data();
      final category = data['category']?.toString() ?? 'General';
      final location = data['locationName']?.toString() ?? '';
      final score = _score(data, interests, preferredCategory, preferredLocation);
      rows.add(SmartRecommendationItem(
        id: doc.id,
        title: data['title']?.toString() ?? 'SwipeBuy listing',
        subtitle: data['description']?.toString() ?? location,
        category: category,
        type: 'Marketplace',
        score: score,
        imageUrl: data['imageUrl']?.toString(),
      ));
    }

    rows.sort((a, b) => b.score.compareTo(a.score));
    return rows.take(limit).toList();
  }

  double _score(
    Map<String, dynamic> data,
    Set<String> interests,
    String? preferredCategory,
    String? preferredLocation,
  ) {
    final category = data['category']?.toString().toLowerCase() ?? '';
    final location = data['locationName']?.toString().toLowerCase() ?? '';
    double score = 0;

    if (interests.contains(category)) score += 35;
    if (preferredCategory != null && preferredCategory == category) score += 30;
    if (preferredLocation != null && location.contains(preferredLocation)) score += 18;

    final rating = (data['averageRating'] as num?)?.toDouble() ?? 0;
    final saves = (data['saves'] as num?)?.toDouble() ?? 0;
    final bookings = (data['bookings'] as num?)?.toDouble() ?? 0;
    final views = (data['views'] as num?)?.toDouble() ?? 0;

    score += rating * 4;
    score += (saves.clamp(0, 500) * 0.8);
    score += (bookings.clamp(0, 200) * 1.5);
    score += (views.clamp(0, 2000) / 250);
    return score;
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    if (uid.isEmpty) return null;
    final snap = await _db.collection('user_preferences').doc(uid).get();
    if (snap.exists) return snap.data();
    final fallback = await _db.collection('users').doc(uid).get();
    return fallback.data();
  }

  Future<void> recordSignal({
    required String recommendationId,
    required String signal,
  }) async {
    if (uid.isEmpty || recommendationId.isEmpty) return;
    await _db.collection('recommendation_events').add({
      'userId': uid,
      'recommendationId': recommendationId,
      'signal': signal,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
