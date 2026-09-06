import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationEventHelper {
  static Future<void> create({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? listingId,
    String? orderId,
    String? bookingId,
    String? senderId,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'read': false,
      if (listingId != null) 'listingId': listingId,
      if (orderId != null) 'orderId': orderId,
      if (bookingId != null) 'bookingId': bookingId,
      if (senderId != null) 'senderId': senderId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
