import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiscoveryProService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Query<Map<String, dynamic>> publishedListings() {
    return _db.collection('listings')
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true);
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> search({
    String query = '',
    String? category,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? action,
  }) async {
    Query<Map<String, dynamic>> q = _db.collection('listings')
        .where('status', isEqualTo: 'published');

    if (category != null && category.trim().isNotEmpty) {
      q = q.where('category', isEqualTo: category.trim());
    }
    if (action != null && action.trim().isNotEmpty) {
      q = q.where('actionType', isEqualTo: action.trim());
    }

    final snap = await q.limit(200).get();
    var docs = snap.docs.toList();

    final needle = query.trim().toLowerCase();
    if (needle.isNotEmpty) {
      docs = docs.where((d) {
        final data = d.data();
        final haystack = [
          data['title'],
          data['description'],
          data['category'],
          data['locationName'],
          data['providerName'],
        ].whereType<String>().join(' ').toLowerCase();
        return haystack.contains(needle);
      }).toList();
    }

    if (latitude != null && longitude != null && radiusKm != null) {
      docs = docs.where((d) {
        final geo = d.data()['location'];
        if (geo is! GeoPoint) return false;
        final distance = _distanceKm(latitude, longitude, geo.latitude, geo.longitude);
        return distance <= radiusKm;
      }).toList();
    }

    docs.sort((a, b) {
      final ad = _distanceScore(a.data(), latitude, longitude);
      final bd = _distanceScore(b.data(), latitude, longitude);
      if (ad != bd) return ad.compareTo(bd);
      return 0;
    });

    return docs;
  }

  double _distanceScore(Map<String, dynamic> data, double? lat, double? lon) {
    if (lat == null || lon == null) return 0;
    final geo = data['location'];
    if (geo is! GeoPoint) return 1e9;
    return _distanceKm(lat, lon, geo.latitude, geo.longitude);
  }

  double _rad(double x) => x * math.pi / 180;
  double _sin2(double x) {
    final s = math.sin(x);
    return s * s;
  }
  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = _sin2(dLat / 2) +
        math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * _sin2(dLon / 2);
    return 2 * r * math.asin(math.sqrt(a.clamp(0.0, 1.0)));
  }
}
