import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Creator events and fan-commerce control plane.
/// Ticket inventory, payments, entitlements and refunds should be enforced server-side.
class CreatorEventsCommerceService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> publishedEvents() {
    return _db.collection('creator_events')
      .where('status', isEqualTo: 'published')
      .orderBy('startAt')
      .limit(50)
      .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myTickets() {
    if (uid.isEmpty) return const Stream.empty();
    return _db.collection('creator_event_tickets')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots();
  }

  Future<void> requestTicket({required String eventId, required String ticketType, required int quantity}) async {
    if (uid.isEmpty || eventId.isEmpty || quantity < 1) return;
    await _db.collection('creator_ticket_requests').add({
      'userId': uid,
      'eventId': eventId,
      'ticketType': ticketType.trim().isEmpty ? 'General' : ticketType.trim(),
      'quantity': quantity,
      'status': 'pending_payment',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestMerch({required String eventId, required String itemId, required int quantity}) async {
    if (uid.isEmpty || eventId.isEmpty || itemId.isEmpty || quantity < 1) return;
    await _db.collection('fan_merch_requests').add({
      'userId': uid,
      'eventId': eventId,
      'itemId': itemId,
      'quantity': quantity,
      'status': 'pending_payment',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestCreatorBundle({required String creatorId, required String bundleId}) async {
    if (uid.isEmpty || creatorId.isEmpty || bundleId.isEmpty) return;
    await _db.collection('creator_bundle_requests').add({
      'userId': uid,
      'creatorId': creatorId,
      'bundleId': bundleId,
      'status': 'pending_payment',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
