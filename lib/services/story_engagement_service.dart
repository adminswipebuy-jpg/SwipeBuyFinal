import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoryEngagementService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Future<void> react(String storyId, String reaction) async {
    if (uid.isEmpty || storyId.isEmpty || reaction.isEmpty) return;
    await _db.collection('storyReactions').doc('${storyId}_$uid').set({
      'storyId': storyId,
      'userId': uid,
      'reaction': reaction,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<String?> myReaction(String storyId) {
    if (uid.isEmpty || storyId.isEmpty) return const Stream.empty();
    return _db.collection('storyReactions').doc('${storyId}_$uid').snapshots().map(
      (d) => d.data()?['reaction']?.toString(),
    );
  }

  Future<void> reply(String storyId, String text) async {
    final value = text.trim();
    if (uid.isEmpty || storyId.isEmpty || value.isEmpty) return;
    await _db.collection('storyReplies').add({
      'storyId': storyId,
      'userId': uid,
      'text': value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
