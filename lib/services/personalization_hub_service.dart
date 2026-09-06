import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalizationHubItem {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String category;
  final double score;

  const PersonalizationHubItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.score,
  });
}

class PersonalizationHubSection {
  final String title;
  final String description;
  final List<PersonalizationHubItem> items;

  const PersonalizationHubSection({
    required this.title,
    required this.description,
    required this.items,
  });
}

class PersonalizationHubService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Future<List<PersonalizationHubSection>> load({int perSection = 6}) async {
    final profile = await _loadProfile();
    final interests = (profile?['interests'] as List?)
            ?.map((e) => e.toString().toLowerCase())
            .toSet() ??
        <String>{};
    final preferredCategory = profile?['preferredCategory']?.toString().toLowerCase();
    final preferredLocation = (profile?['location'] ?? profile?['preferredLocation'])?.toString().toLowerCase();

    final configs = <Map<String, String>>[
      {'collection': 'listings', 'type': 'Marketplace', 'section': 'For You'},
      {'collection': 'jobs', 'type': 'Jobs', 'section': 'Opportunities'},
      {'collection': 'properties', 'type': 'Property', 'section': 'Places for You'},
      {'collection': 'professionals', 'type': 'Services', 'section': 'Services for You'},
      {'collection': 'content', 'type': 'Content', 'section': 'Content for You'},
    ];

    final sections = <PersonalizationHubSection>[];
    for (final config in configs) {
      final items = await _loadCollection(
        collection: config['collection']!,
        type: config['type']!,
        interests: interests,
        preferredCategory: preferredCategory,
        preferredLocation: preferredLocation,
        limit: perSection,
      );
      if (items.isNotEmpty) {
        sections.add(PersonalizationHubSection(
          title: config['section']!,
          description: _descriptionFor(config['type']!),
          items: items,
        ));
      }
    }
    return sections;
  }

  Future<List<PersonalizationHubItem>> _loadCollection({
    required String collection,
    required String type,
    required Set<String> interests,
    required String? preferredCategory,
    required String? preferredLocation,
    required int limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db.collection(collection);
      query = query.where('status', isEqualTo: 'published');
      final snap = await query.limit(100).get();
      final items = <PersonalizationHubItem>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final title = (data['title'] ?? data['name'] ?? data['businessName'] ?? 'SwipeBuy item').toString();
        final category = (data['category'] ?? data['type'] ?? type).toString();
        final location = (data['locationText'] ?? data['locationName'] ?? data['location'] ?? '').toString();
        final subtitle = (data['description'] ?? data['role'] ?? data['company'] ?? location).toString();
        final score = _score(data, title, category, location, interests, preferredCategory, preferredLocation);
        items.add(PersonalizationHubItem(
          id: doc.id,
          type: type,
          title: title,
          subtitle: subtitle,
          category: category,
          score: score,
        ));
      }
      items.sort((a, b) => b.score.compareTo(a.score));
      return items.take(limit).toList();
    } catch (_) {
      return const [];
    }
  }

  double _score(
    Map<String, dynamic> data,
    String title,
    String category,
    String location,
    Set<String> interests,
    String? preferredCategory,
    String? preferredLocation,
  ) {
    final c = category.toLowerCase();
    final l = location.toLowerCase();
    final t = title.toLowerCase();
    double score = 0;
    if (interests.contains(c)) score += 35;
    if (preferredCategory != null && preferredCategory == c) score += 30;
    if (preferredLocation != null && l.contains(preferredLocation)) score += 18;
    if (interests.any((interest) => interest.length > 2 && (t.contains(interest) || c.contains(interest)))) {
      score += 10;
    }
    score += ((data['averageRating'] as num?)?.toDouble() ?? 0).clamp(0, 5) * 4;
    score += ((data['saves'] as num?)?.toDouble() ?? 0).clamp(0, 500) * 0.4;
    score += ((data['views'] as num?)?.toDouble() ?? 0).clamp(0, 2000) / 250;
    return score;
  }

  String _descriptionFor(String type) {
    switch (type) {
      case 'Jobs': return 'Roles and gigs matched to your interests.';
      case 'Property': return 'Properties that fit your preferences.';
      case 'Services': return 'Professionals and services worth exploring.';
      case 'Content': return 'Fresh content selected for you.';
      default: return 'Personalized picks based on your SwipeBuy activity.';
    }
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    if (uid.isEmpty) return null;
    final prefs = await _db.collection('user_preferences').doc(uid).get();
    if (prefs.exists) return prefs.data();
    final user = await _db.collection('users').doc(uid).get();
    return user.data();
  }

  Future<void> recordSignal({required String itemId, required String type, required String signal}) async {
    if (uid.isEmpty || itemId.isEmpty) return;
    try {
      await _db.collection('recommendation_events').add({
        'userId': uid,
        'recommendationId': itemId,
        'type': type,
        'signal': signal,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
