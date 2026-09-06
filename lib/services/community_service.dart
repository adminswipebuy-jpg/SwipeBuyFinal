import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> discover({String? category}) {
    Query<Map<String, dynamic>> q = _db.collection('communities').where('status', isEqualTo: 'active').orderBy('memberCount', descending: true).limit(50);
    if (category != null && category.isNotEmpty) {
      q = _db.collection('communities').where('status', isEqualTo: 'active').where('category', isEqualTo: category).orderBy('memberCount', descending: true).limit(50);
    }
    return q.snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myCommunities() {
    if (uid.isEmpty) return _db.collection('communityMembers').where('userId', isEqualTo: '__none__').snapshots();
    return _db.collection('communityMembers').where('userId', isEqualTo: uid).orderBy('joinedAt', descending: true).snapshots();
  }

  Future<void> join(String communityId) async {
    if (uid.isEmpty || communityId.isEmpty) return;
    final member = _db.collection('communities').doc(communityId).collection('members').doc(uid);
    final index = _db.collection('communityMembers').doc('${uid}_$communityId');
    final community = _db.collection('communities').doc(communityId);
    final batch = _db.batch();
    batch.set(member, {'userId': uid, 'joinedAt': FieldValue.serverTimestamp(), 'role': 'member'});
    batch.set(index, {'userId': uid, 'communityId': communityId, 'joinedAt': FieldValue.serverTimestamp()});
    batch.update(community, {'memberCount': FieldValue.increment(1), 'updatedAt': FieldValue.serverTimestamp()});
    await batch.commit();
  }

  Future<void> leave(String communityId) async {
    if (uid.isEmpty || communityId.isEmpty) return;
    final member = _db.collection('communities').doc(communityId).collection('members').doc(uid);
    final index = _db.collection('communityMembers').doc('${uid}_$communityId');
    final community = _db.collection('communities').doc(communityId);
    final batch = _db.batch();
    batch.delete(member);
    batch.delete(index);
    batch.update(community, {'memberCount': FieldValue.increment(-1), 'updatedAt': FieldValue.serverTimestamp()});
    await batch.commit();
  }


  Stream<DocumentSnapshot<Map<String, dynamic>>> membership(String communityId) {
    if (uid.isEmpty) return _db.collection('communities').doc(communityId).collection('members').doc('__none__').snapshots();
    return _db.collection('communities').doc(communityId).collection('members').doc(uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> posts(String communityId) {
    return _db.collection('communities').doc(communityId).collection('posts').orderBy('createdAt', descending: true).limit(100).snapshots();
  }

  Future<void> createPost({required String communityId, required String text}) async {
    if (uid.isEmpty || communityId.isEmpty || text.trim().isEmpty) return;
    await _db.collection('communities').doc(communityId).collection('posts').add({
      'authorId': uid,
      'authorName': _auth.currentUser?.displayName ?? 'SwipeBuy member',
      'text': text.trim(),
      'likes': 0,
      'comments': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'published',
    });
  }

  Future<void> createCommunity({required String name, required String description, required String category}) async {
    if (uid.isEmpty || name.trim().isEmpty) return;
    final ref = _db.collection('communities').doc();
    await ref.set({
      'name': name.trim(),
      'description': description.trim(),
      'category': category,
      'ownerId': uid,
      'status': 'active',
      'memberCount': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await join(ref.id);
  }
}
