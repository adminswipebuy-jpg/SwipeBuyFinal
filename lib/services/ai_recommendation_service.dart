import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiRecommendationService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  /// Client-side ranking foundation. Production ranking should be server-controlled.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> rankedFeed({
    String? category,
    String? locationName,
    int limit = 50,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection('listings')
        .where('status', isEqualTo: 'published');

    if (category != null && category.trim().isNotEmpty) {
      query = query.where('category', isEqualTo: category.trim());
    }

    final snap = await query.limit(200).get();
    final docs = snap.docs.toList();

    final profile = await _loadProfile();
    final preferredCategory = profile?['preferredCategory']?.toString();
    final preferredLocation = profile?['preferredLocation']?.toString();

    docs.sort((a, b) {
      final sa = _score(a.data(), preferredCategory, preferredLocation, locationName);
      final sb = _score(b.data(), preferredCategory, preferredLocation, locationName);
      return sb.compareTo(sa);
    });

    return docs.take(limit).toList();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    if (uid.isEmpty) return null;
    final snap = await _db.collection('users').doc(uid).get();
    return snap.data();
  }

  double _score(
    Map<String, dynamic> data,
    String? preferredCategory,
    String? preferredLocation,
    String? currentLocation,
  ) {
    double score = 0;

    if (preferredCategory != null &&
        data['category']?.toString().toLowerCase() == preferredCategory.toLowerCase()) {
      score += 30;
    }

    final targetLocation = currentLocation ?? preferredLocation;
    if (targetLocation != null &&
        data['locationName']?.toString().toLowerCase().contains(targetLocation.toLowerCase()) == true) {
      score += 20;
    }

    final rating = (data['averageRating'] as num?)?.toDouble() ?? 0;
    score += rating * 4;

    final views = (data['views'] as num?)?.toDouble() ?? 0;
    final saves = (data['saves'] as num?)?.toDouble() ?? 0;
    final bookings = (data['bookings'] as num?)?.toDouble() ?? 0;
    score += (saves * 2) + (bookings * 5) + (views.clamp(0, 1000) / 100);

    return score;
  }

  Future<void> recordRecommendationSignal({
    required String listingId,
    required String signal,
    double value = 1,
  }) async {
    if (uid.isEmpty || listingId.isEmpty) return;
    await _db.collection('listing_events').add({
      'listingId': listingId,
      'userId': uid,
      'eventType': signal,
      'value': value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
