import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Backend-first creator membership/subscription foundation.
/// The client stores preferences and sends subscription requests only;
/// trusted backend/payment systems must verify entitlements, billing,
/// renewals, refunds and access to premium content.
class CreatorMembershipService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  User get _user => _auth.currentUser!;
  String get uid => _user.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> myPlans() => _db
      .collection('creator_membership_plans')
      .where('creatorId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> myMemberships() => _db
      .collection('creator_memberships')
      .where('memberId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots();

  Future<String> createPlan({
    required String name,
    required String description,
    required double monthlyPrice,
    required String currency,
    required String perks,
  }) async {
    if (name.trim().length < 3) throw Exception('Enter a membership name.');
    if (monthlyPrice < 0) throw Exception('Price cannot be negative.');
    final ref = await _db.collection('creator_membership_plans').add({
      'creatorId': uid,
      'name': name.trim(),
      'description': description.trim(),
      'monthlyPrice': monthlyPrice,
      'currency': currency.trim().toUpperCase(),
      'perks': perks.trim(),
      'status': 'draft',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<String> requestMembership({
    required String creatorId,
    required String planId,
    required String note,
  }) async {
    if (creatorId.trim().isEmpty || planId.trim().isEmpty) throw Exception('Creator and plan are required.');
    final ref = await _db.collection('creator_subscription_requests').add({
      'memberId': uid,
      'creatorId': creatorId.trim(),
      'planId': planId.trim(),
      'note': note.trim(),
      'status': 'pending_payment',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> cancelMembership(String membershipId) async {
    await _db.collection('creator_memberships').doc(membershipId).update({
      'status': 'cancel_requested',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestPayout({required double amount, required String currency}) async {
    if (amount <= 0) throw Exception('Payout amount must be greater than zero.');
    await _db.collection('creator_membership_payout_requests').add({
      'creatorId': uid,
      'amount': amount,
      'currency': currency.trim().toUpperCase(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
