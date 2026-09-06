
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> providerBookings() {
    return _db.collection('bookings')
      .where('providerId', isEqualTo: uid)
      .orderBy('startAt').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> customerBookings() {
    return _db.collection('bookings')
      .where('customerId', isEqualTo: uid)
      .orderBy('startAt').snapshots();
  }

  Future<String> requestBooking({
    required String providerId,
    required String listingId,
    required DateTime startAt,
    required DateTime endAt,
    required String note,
  }) async {
    if (!endAt.isAfter(startAt)) throw Exception('End time must be after start time.');
    final ref = await _db.collection('bookings').add({
      'customerId': uid,
      'providerId': providerId,
      'listingId': listingId,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'note': note.trim(),
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> cancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
