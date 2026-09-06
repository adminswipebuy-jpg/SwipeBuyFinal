import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonetizationService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  User get _user => _auth.currentUser!;
  String get uid => _user.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> creatorEarnings() => _db
      .collection('users')
      .doc(uid)
      .collection('creator_earnings')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> campaigns() => _db
      .collection('ad_campaigns')
      .where('ownerId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots();

  Future<String> createCampaignDraft({
    required String name,
    required String objective,
    required double dailyBudget,
  }) async {
    if (name.trim().length < 3) throw Exception('Campaign name is too short');
    if (dailyBudget <= 0) throw Exception('Budget must be greater than zero');
    final ref = await _db.collection('ad_campaigns').add({
      'ownerId': uid,
      'name': name.trim(),
      'objective': objective,
      'dailyBudget': dailyBudget,
      'status': 'draft',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<String> requestPayout({required double amount, required String method}) async {
    if (amount <= 0) throw Exception('Amount must be greater than zero');
    final ref = await _db.collection('payout_requests').add({
      'creatorId': uid,
      'amount': amount,
      'method': method,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
