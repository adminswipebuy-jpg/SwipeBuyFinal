import 'package:cloud_firestore/cloud_firestore.dart';

class UniversalAiResult {
  final String type;
  final String title;
  final String subtitle;
  final String action;
  final String? imageUrl;
  final Map<String, dynamic> data;

  const UniversalAiResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.action,
    this.imageUrl,
    this.data = const {},
  });
}

class UniversalAiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const _collectionHints = <String, List<String>>{
    'products': ['product', 'phone', 'shop', 'buy', 'price'],
    'jobs': ['job', 'work', 'hire', 'career', 'driver', 'remote'],
    'property': ['house', 'home', 'apartment', 'land', 'property', 'rent'],
    'sports': ['football', 'sport', 'match', 'score', 'player', 'team'],
    'finance': ['forex', 'crypto', 'bitcoin', 'stock', 'investment', 'currency'],
    'education': ['learn', 'course', 'school', 'education', 'study'],
    'services': ['service', 'designer', 'developer', 'accountant', 'doctor'],
    'travel': ['travel', 'hotel', 'tour', 'flight', 'vacation'],
  };

  Future<List<UniversalAiResult>> answer(String prompt, {int limit = 24}) async {
    final text = prompt.trim().toLowerCase();
    if (text.isEmpty) return [];

    final intent = _detectIntent(text);
    final queries = <Future<List<UniversalAiResult>>>[];

    if (intent == 'all' || intent == 'products') queries.add(_searchCollection('listings', text, 'Products'));
    if (intent == 'all' || intent == 'jobs') queries.add(_searchCollection('jobs', text, 'Jobs'));
    if (intent == 'all' || intent == 'property') queries.add(_searchCollection('properties', text, 'Property'));
    if (intent == 'all' || intent == 'sports') queries.add(_searchCollection('content', text, 'Sports'));
    if (intent == 'all' || intent == 'finance') queries.add(_searchCollection('content', text, 'Finance'));
    if (intent == 'all' || intent == 'education') queries.add(_searchCollection('content', text, 'Education'));
    if (intent == 'all' || intent == 'services') queries.add(_searchCollection('professionals', text, 'Services'));
    if (intent == 'all' || intent == 'travel') queries.add(_searchCollection('listings', text, 'Travel'));

    final chunks = await Future.wait(queries);
    final results = chunks.expand((x) => x).toList();
    final unique = <String, UniversalAiResult>{};
    for (final r in results) {
      unique['${r.type}|${r.title}|${r.subtitle}'] = r;
    }
    final sorted = unique.values.toList();
    sorted.sort((a, b) => _score(b, text).compareTo(_score(a, text)));
    return sorted.take(limit).toList();
  }

  String _detectIntent(String text) {
    String? best;
    var score = 0;
    _collectionHints.forEach((key, hints) {
      final hits = hints.where(text.contains).length;
      if (hits > score) {
        score = hits;
        best = key;
      }
    });
    return best ?? 'all';
  }

  int _score(UniversalAiResult result, String query) {
    final hay = '${result.title} ${result.subtitle}'.toLowerCase();
    var score = result.type == 'Products' ? 2 : 1;
    for (final token in query.split(RegExp(r'\\s+'))) {
      if (token.length >= 3 && hay.contains(token)) score += 3;
    }
    return score;
  }

  Future<List<UniversalAiResult>> _searchCollection(
    String collection,
    String query,
    String type,
  ) async {
    try {
      final snap = await _db.collection(collection).limit(120).get();
      final results = <UniversalAiResult>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final title = _firstString(data, ['title', 'name', 'businessName', 'role']) ?? 'SwipeBuy item';
        final subtitle = _firstString(data, ['description', 'subtitle', 'category', 'locationName', 'locationText']) ?? type;
        final hay = '${title} ${subtitle} ${data['category'] ?? ''} ${data['seller'] ?? ''}'.toLowerCase();
        final tokens = query.split(RegExp(r'\\s+')).where((x) => x.length >= 3);
        if (tokens.isEmpty || tokens.any(hay.contains)) {
          results.add(UniversalAiResult(
            type: type,
            title: title,
            subtitle: subtitle,
            action: _actionFor(type, data),
            imageUrl: data['imageUrl']?.toString(),
            data: {'id': doc.id, ...data},
          ));
        }
      }
      return results;
    } catch (_) {
      // Missing collections are expected during early development; the assistant
      // simply returns results from collections that are available.
      return [];
    }
  }

  String? _firstString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'null') return value;
    }
    return null;
  }

  String _actionFor(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'Jobs': return 'Apply';
      case 'Property': return 'View';
      case 'Sports': return 'Read';
      case 'Finance': return 'Open';
      case 'Education': return 'Learn';
      case 'Services': return 'Hire';
      case 'Travel': return 'Book';
      default: return data['actionLabel']?.toString() ?? 'View';
    }
  }
}
