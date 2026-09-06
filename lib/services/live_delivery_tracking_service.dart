import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LiveDeliveryTrackingService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<DocumentSnapshot<Map<String, dynamic>>> order(String orderId) =>
      _db.collection('orders').doc(orderId).snapshots();

  Future<void> updateCourierLocation({
    required String orderId,
    required double latitude,
    required double longitude,
    double? heading,
  }) async {
    if (uid.isEmpty) return;
    // Foundation only. Production must use a trusted backend after verifying
    // courier assignment, consent, rate limits and location accuracy.
    await _db.collection('orders').doc(orderId).update({
      'courierLocation': GeoPoint(latitude, longitude),
      if (heading != null) 'courierHeading': heading,
      'courierLocationUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  double? estimateDistanceKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    // Placeholder straight-line estimate. Use Google Maps Routes/Navigation
    // or another routing backend for production road distance and ETA.
    final dLat = (toLat - fromLat).abs();
    final dLng = (toLng - fromLng).abs();
    return ((dLat * dLat + dLng * dLng) ** 0.5) * 111.0;
  }
}
