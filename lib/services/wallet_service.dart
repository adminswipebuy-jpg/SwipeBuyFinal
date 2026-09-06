import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _wallet =>
      _db.collection('wallets').doc(uid);

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchWallet() =>
      _wallet.snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchTransactions() => _wallet
      .collection('transactions')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots();

  Future<void> requestDeposit({required double amount, required String provider}) async {
    if (amount <= 0) throw ArgumentError('Amount must be greater than zero.');
    await _db.collection('wallet_deposit_requests').add({
      'userId': uid,
      'amount': amount,
      'provider': provider,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestWithdrawal({required double amount, required String method}) async {
    if (amount <= 0) throw ArgumentError('Amount must be greater than zero.');
    await _db.collection('wallet_withdrawal_requests').add({
      'userId': uid,
      'amount': amount,
      'method': method,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
