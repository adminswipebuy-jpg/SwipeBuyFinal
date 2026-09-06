import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ProfessionalBookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> streamMyBookings() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('professional_bookings').where('clientId', isEqualTo: uid).snapshots().map((s) {
      final rows = s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      rows.sort((a,b) => ((b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0).compareTo((a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0));
      return rows;
    });
  }

  Future<void> requestBooking({required String serviceId, required String providerName, required DateTime requestedStart, required int durationMinutes, required String note}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('professional_bookings').add({
      'clientId': uid,
      'serviceId': serviceId,
      'providerName': providerName,
      'requestedStart': Timestamp.fromDate(requestedStart),
      'durationMinutes': durationMinutes,
      'note': note.trim(),
      'status': 'pending_provider_confirmation',
      'contractStatus': 'not_started',
      'paymentStatus': 'not_started',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestContract({required String bookingId}) async {
    await _db.collection('professional_bookings').doc(bookingId).update({
      'contractStatus': 'requested',
      'status': 'pending_backend_confirmation',
    });
  }

  Future<void> cancelBooking({required String bookingId}) async {
    await _db.collection('professional_bookings').doc(bookingId).update({'status': 'cancellation_requested'});
  }
}
