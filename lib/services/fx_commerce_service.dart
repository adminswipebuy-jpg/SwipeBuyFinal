import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FxCommerceService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Please sign in first.');
    return uid;
  }

  Future<void> saveCommercePreferences({
    required String displayCurrency,
    required bool showLocalCurrency,
    required bool showEstimatedFx,
  }) async {
    await _db.collection('users').doc(_uid).collection('settings').doc('fxCommerce').set({
      'displayCurrency': displayCurrency,
      'showLocalCurrency': showLocalCurrency,
      'showEstimatedFx': showEstimatedFx,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> requestQuote({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final ref = await _db.collection('fxQuoteRequests').add({
      'uid': _uid,
      'amount': amount,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'status': 'requested',
      'source': 'swipebuy_client',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> recentQuotes() {
    return _db
        .collection('fxQuoteRequests')
        .where('uid', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }
}
