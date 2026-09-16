import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class NearbyItem {
  final String id;
  final String title;
  final String category;
  final String subtitle;
  final String location;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final bool verified;

  const NearbyItem({
    required this.id,
    required this.title,
    required this.category,
    required this.subtitle,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.verified = false,
  });
}

class LocalDiscoveryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Position> currentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationServiceDisabledException();
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw const PermissionDeniedException('Location permission denied');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 100,
      ),
    );
  }

  Future<List<NearbyItem>> nearby({
    required double latitude,
    required double longitude,
    String? category,
    double radiusKm = 25,
  }) async {
    try {
      Query<Map<String, dynamic>> q = _db
          .collection('listings')
          .where('status', isEqualTo: 'published')
          .limit(100);
      if (category != null && category.isNotEmpty) {
        q = q.where('category', isEqualTo: category);
      }
      final snap = await q.get();
      final items = <NearbyItem>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final lat = _number(data['latitude']);
        final lng = _number(data['longitude']);
        if (lat == null || lng == null) continue;
        final meters = Geolocator.distanceBetween(latitude, longitude, lat, lng);
        final distanceKm = meters / 1000;
        if (distanceKm > radiusKm) continue;
        items.add(NearbyItem(
          id: doc.id,
          title: '${data['title'] ?? 'Untitled'}',
          category: '${data['category'] ?? 'Other'}',
          subtitle: '${data['subtitle'] ?? data['description'] ?? ''}',
          location: '${data['locationText'] ?? data['location'] ?? 'Nearby'}',
          latitude: lat,
          longitude: lng,
          distanceKm: distanceKm,
          verified: data['verified'] == true,
        ));
      }
      items.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return items;
    } catch (_) {
      return const [];
    }
  }

  static double? _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  double demoDistance(double fromLat, double fromLng, double toLat, double toLng) {
    const earthRadiusKm = 6371.0;
    final dLat = _rad(toLat - fromLat);
    final dLng = _rad(toLng - fromLng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(fromLat)) *
            math.cos(_rad(toLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _rad(double degrees) => degrees * math.pi / 180;
}
