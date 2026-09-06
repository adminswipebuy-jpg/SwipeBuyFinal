import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RealtimeChatService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  String conversationIdFor(String otherUid) {
    final ids = [uid, otherUid]..sort();
    return ids.join('_');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> conversations() {
    if (uid.isEmpty) {
      return _db.collection('conversations')
          .where('memberIds', arrayContains: '__none__').snapshots();
    }
    return _db.collection('conversations')
        .where('memberIds', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messages(String conversationId) {
    return _db.collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> sendMessage({
    required String conversationId,
    required String recipientId,
    required String text,
  }) async {
    final body = text.trim();
    if (uid.isEmpty || body.isEmpty || recipientId.isEmpty) return;

    final conversation = _db.collection('conversations').doc(conversationId);
    final message = conversation.collection('messages').doc();

    final batch = _db.batch();
    batch.set(message, {
      'senderId': uid,
      'recipientId': recipientId,
      'text': body,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [uid],
    });
    batch.set(conversation, {
      'memberIds': [uid, recipientId],
      'lastMessage': body,
      'lastSenderId': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> markMessageRead(String conversationId, String messageId) async {
    if (uid.isEmpty) return;
    await _db.collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .update({'readBy': FieldValue.arrayUnion([uid])});
  }
}
