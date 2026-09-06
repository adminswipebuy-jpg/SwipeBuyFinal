import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SocialService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String get uid => _auth.currentUser?.uid ?? '';

  Future<void> followProvider(String providerId) async {
    if (uid.isEmpty || providerId.isEmpty || uid == providerId) return;
    await _db.collection('follows').doc('${uid}_$providerId').set({'followerId': uid, 'providerId': providerId, 'createdAt': FieldValue.serverTimestamp()});
  }
  Future<void> unfollowProvider(String providerId) async => _db.collection('follows').doc('${uid}_$providerId').delete();
  Stream<bool> isFollowing(String providerId) => _db.collection('follows').doc('${uid}_$providerId').snapshots().map((d) => d.exists);

  Future<void> likeListing(String listingId) async => _db.collection('likes').doc('${uid}_$listingId').set({'userId': uid, 'listingId': listingId, 'createdAt': FieldValue.serverTimestamp()});
  Future<void> unlikeListing(String listingId) async => _db.collection('likes').doc('${uid}_$listingId').delete();
  Stream<bool> isLiked(String listingId) => _db.collection('likes').doc('${uid}_$listingId').snapshots().map((d) => d.exists);

  Future<void> saveListing(String listingId) async => _db.collection('saves').doc('${uid}_$listingId').set({'userId': uid, 'listingId': listingId, 'createdAt': FieldValue.serverTimestamp()});
  Future<void> unsaveListing(String listingId) async => _db.collection('saves').doc('${uid}_$listingId').delete();
  Stream<bool> isSaved(String listingId) => _db.collection('saves').doc('${uid}_$listingId').snapshots().map((d) => d.exists);

  Future<void> addComment(String listingId, String text) async {
    final value = text.trim();
    if (uid.isEmpty || listingId.isEmpty || value.isEmpty) return;
    await _db.collection('comments').add({'listingId': listingId, 'userId': uid, 'text': value, 'createdAt': FieldValue.serverTimestamp()});
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> comments(String listingId) => _db.collection('comments').where('listingId', isEqualTo: listingId).orderBy('createdAt').snapshots();
  Future<void> recordShare(String listingId) async => _db.collection('listing_events').add({'listingId': listingId, 'userId': uid, 'eventType': 'share', 'createdAt': FieldValue.serverTimestamp()});
}
