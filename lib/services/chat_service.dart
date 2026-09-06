
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> myChats() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('chats').where('participantIds', arrayContains: uid)
      .orderBy('updatedAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messages(String chatId) {
    return _db.collection('chats').doc(chatId).collection('messages')
      .orderBy('createdAt').snapshots();
  }

  Future<void> sendMessage(String chatId, String text) async {
    final uid = _auth.currentUser?.uid;
    final value = text.trim();
    if (uid == null || value.isEmpty) return;
    final chat = _db.collection('chats').doc(chatId);
    await chat.collection('messages').add({
      'senderId': uid,
      'text': value,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await chat.update({
      'lastMessage': value,
      'lastSenderId': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
