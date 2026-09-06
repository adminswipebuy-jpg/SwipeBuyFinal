import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Backend-first creator/brand partnership workflow.
/// The client only creates proposals/requests; approvals, contracts,
/// payments, disclosures and eligibility must be enforced by trusted backend systems.
class CreatorBrandPartnershipService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  User get _user => _auth.currentUser!;
  String get uid => _user.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> myPartnerships() => _db
      .collection('creator_brand_partnerships')
      .where('creatorId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots();

  Future<String> createProposal({
    required String brandName,
    required String campaign,
    required String deliverables,
    required String proposedFee,
    required String disclosure,
  }) async {
    if (brandName.trim().length < 2) throw Exception('Enter a brand name.');
    if (campaign.trim().length < 3) throw Exception('Enter a campaign name.');
    final ref = await _db.collection('creator_brand_partnerships').add({
      'creatorId': uid,
      'brandName': brandName.trim(),
      'campaign': campaign.trim(),
      'deliverables': deliverables.trim(),
      'proposedFee': proposedFee.trim(),
      'disclosure': disclosure.trim(),
      'status': 'proposal',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> requestReview(String id) async {
    await _db.collection('creator_brand_partnerships').doc(id).update({
      'status': 'review_requested',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
