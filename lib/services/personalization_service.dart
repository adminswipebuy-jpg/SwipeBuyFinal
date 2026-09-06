import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalizationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  static const defaultInterests = [
    'Sports', 'News', 'Shopping', 'Jobs', 'Education', 'Finance',
    'Crypto', 'Forex', 'Investment', 'Real Estate', 'Fitness', 'Lifestyle',
    'Travel', 'Entertainment', 'Food', 'Services',
  ];

  Future<Map<String, dynamic>> loadPreferences() async {
    if (uid.isEmpty) return {
      'interests': <String>[],
      'location': 'Worldwide',
      'language': 'English',
      'showNearby': true,
    };
    final snap = await _db.collection('user_preferences').doc(uid).get();
    if (!snap.exists) {
      return {
        'interests': <String>[],
        'location': 'Worldwide',
        'language': 'English',
        'showNearby': true,
      };
    }
    return snap.data()!;
  }

  Future<void> savePreferences({
    required List<String> interests,
    required String location,
    required String language,
    required bool showNearby,
  }) async {
    if (uid.isEmpty) return;
    await _db.collection('user_preferences').doc(uid).set({
      'interests': interests,
      'location': location.trim().isEmpty ? 'Worldwide' : location.trim(),
      'language': language,
      'showNearby': showNearby,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> personalizedContent({int limit = 30}) async {
    final prefs = await loadPreferences();
    final interests = ((prefs['interests'] as List?) ?? const [])
        .map((e) => e.toString().toLowerCase()).toSet();
    final location = (prefs['location'] ?? 'Worldwide').toString().toLowerCase();
    final showNearby = prefs['showNearby'] != false;

    try {
      final snap = await _db.collection('content_items')
          .where('status', isEqualTo: 'published')
          .limit(150)
          .get();
      final docs = snap.docs.toList();
      docs.sort((a, b) => _score(b.data(), interests, location, showNearby)
          .compareTo(_score(a.data(), interests, location, showNearby)));
      return docs.take(limit).map((d) => {...d.data(), '_id': d.id}).toList();
    } catch (_) {
      return [];
    }
  }

  double _score(Map<String, dynamic> data, Set<String> interests, String location, bool showNearby) {
    final category = (data['category'] ?? '').toString().toLowerCase();
    final itemLocation = (data['location'] ?? data['locationName'] ?? '').toString().toLowerCase();
    final score = <double>[];
    var total = 0.0;
    if (interests.contains(category)) total += 60;
    if (showNearby && location != 'worldwide' && itemLocation.contains(location)) total += 25;
    final likes = (data['likes'] as num?)?.toDouble() ?? 0;
    final shares = (data['shares'] as num?)?.toDouble() ?? 0;
    final comments = (data['comments'] as num?)?.toDouble() ?? 0;
    final views = (data['views'] as num?)?.toDouble() ?? 0;
    final quality = (data['qualityScore'] as num?)?.toDouble() ?? 0;
    total += likes.clamp(0, 100000) / 2500;
    total += shares.clamp(0, 50000) / 1800;
    total += comments.clamp(0, 50000) / 3000;
    total += views.clamp(0, 250000) / 25000;
    total += quality * 4;
    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) {
      final hours = DateTime.now().difference(createdAt.toDate()).inHours.clamp(0, 168);
      total += (168 - hours) / 14;
    }
    score.add(total);
    return score.single;
  }

  Future<List<String>> categoryOrder(List<String> available) async {
    final prefs = await loadPreferences();
    final interests = ((prefs['interests'] as List?) ?? const [])
        .map((e) => e.toString().toLowerCase()).toSet();
    final preferred = <String>[];
    final rest = <String>[];
    for (final category in available) {
      if (interests.contains(category.toLowerCase())) {
        preferred.add(category);
      } else {
        rest.add(category);
      }
    }
    return [...preferred, ...rest];
  }

  Future<void> resetRecommendations() async {
    if (uid.isEmpty) return;
    await _db.collection('user_preferences').doc(uid).set({
      'interests': <String>[],
      'resetAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
