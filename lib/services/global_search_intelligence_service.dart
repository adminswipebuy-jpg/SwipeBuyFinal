import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlobalSearchResult {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String category;
  final double score;

  const GlobalSearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.score,
  });
}

class GlobalSearchIntelligenceService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Future<List<GlobalSearchResult>> search(String rawQuery, {String mode = 'All', int limit = 40}) async {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) return [];

    final tokens = query.split(RegExp(r'\\s+')).where((x) => x.isNotEmpty).toSet();
    final collections = <String, String>{
      'listings': 'Marketplace',
      'jobs': 'Jobs',
      'properties': 'Property',
      'professionals': 'Services',
      'content': 'Content',
    };

    final tasks = <Future<List<GlobalSearchResult>>>[];
    for (final entry in collections.entries) {
      if (mode != 'All' && entry.value != mode) continue;
      tasks.add(_searchCollection(entry.key, entry.value, query, tokens));
    }

    final groups = await Future.wait(tasks);
    final merged = groups.expand((x) => x).toList();
    merged.sort((a, b) => b.score.compareTo(a.score));

    if (uid.isNotEmpty) {
      await _recordSearch(query, mode);
    }
    return merged.take(limit).toList();
  }

  Future<List<GlobalSearchResult>> _searchCollection(
    String collection,
    String type,
    String query,
    Set<String> tokens,
  ) async {
    try {
      Query<Map<String, dynamic>> ref = _db.collection(collection);
      if ({'listings', 'jobs', 'properties', 'content'}.contains(collection)) {
        ref = ref.where('status', isEqualTo: 'published');
      }
      final snap = await ref.limit(120).get();
      final results = <GlobalSearchResult>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final title = (data['title'] ?? data['name'] ?? data['businessName'] ?? 'SwipeBuy result').toString();
        final category = (data['category'] ?? data['type'] ?? type).toString();
        final subtitle = (data['locationText'] ?? data['locationName'] ?? data['description'] ?? data['role'] ?? '').toString();
        final haystack = '$title $category $subtitle ${data['seller'] ?? ''} ${data['company'] ?? ''}'.toLowerCase();
        final score = _score(haystack, title.toLowerCase(), category.toLowerCase(), query, tokens, data);
        if (score > 0) {
          results.add(GlobalSearchResult(
            id: doc.id,
            type: type,
            title: title,
            subtitle: subtitle,
            category: category,
            score: score,
          ));
        }
      }
      return results;
    } catch (_) {
      return const [];
    }
  }

  double _score(
    String haystack,
    String title,
    String category,
    String query,
    Set<String> tokens,
    Map<String, dynamic> data,
  ) {
    double score = 0;
    if (title == query) score += 100;
    if (title.contains(query)) score += 55;
    if (category.contains(query)) score += 35;
    if (haystack.contains(query)) score += 25;
    for (final token in tokens) {
      if (token.length < 2) continue;
      if (title.contains(token)) score += 18;
      if (haystack.contains(token)) score += 5;
    }
    final rating = (data['averageRating'] as num?)?.toDouble() ?? 0;
    final saves = (data['saves'] as num?)?.toDouble() ?? 0;
    score += rating.clamp(0, 5) * 2;
    score += saves.clamp(0, 100) * 0.08;
    return score;
  }

  Future<List<String>> suggestions(String rawQuery) async {
    final q = rawQuery.trim();
    if (q.isEmpty) return const [
      'Jobs near me',
      'Apartments for rent',
      'Best restaurants',
      'Football news',
      'Forex today',
      'Phone deals',
    ];
    return [
      '$q near me',
      'best $q',
      '$q jobs',
      '$q prices',
      '$q deals',
    ];
  }

  Future<void> _recordSearch(String query, String mode) async {
    try {
      await _db.collection('search_events').add({
        'userId': uid,
        'query': query,
        'mode': mode,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Search should still work even when analytics logging is unavailable.
    }
  }
}
