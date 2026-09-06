import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Stores user payment preferences only. Actual payment authorization must be
/// performed by a trusted provider/backend; the client never marks an order paid.
class GlobalPaymentService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid {
    final user = _auth.currentUser;
    if (user == null) throw StateError('You must be signed in.');
    return user.uid;
  }

  Future<void> savePreferences({
    required String country,
    required String currency,
    required String provider,
  }) async {
    await _db.collection('users').doc(uid).collection('payment_preferences').doc('default').set({
      'country': country,
      'currency': currency,
      'provider': provider,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchPreferences() =>
      _db.collection('users').doc(uid).collection('payment_preferences').doc('default').snapshots();
}
