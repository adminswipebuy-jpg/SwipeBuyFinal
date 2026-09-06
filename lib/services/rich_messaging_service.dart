import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RichMessagingService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  String conversationIdFor(String otherUid) {
    final ids = [uid, otherUid]..sort();
    return ids.join('_');
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> conversation(String id) =>
      _db.collection('conversations').doc(id).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> messages(String id) =>
      _db.collection('conversations').doc(id).collection('messages')
          .orderBy('createdAt').snapshots();

  Future<void> setTyping({required String conversationId, required bool typing}) async {
    if (uid.isEmpty) return;
    await _db.collection('conversations').doc(conversationId).set({
      'typing': {uid: typing},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> uploadAttachment(File file, {required String kind}) async {
    if (uid.isEmpty) throw StateError('You must be signed in.');
    final ext = kind == 'video' ? 'mp4' : kind == 'voice' ? 'm4a' : 'jpg';
    final ref = _storage.ref('users/$uid/chat/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: '$kind/${ext == 'jpg' ? 'jpeg' : ext}'));
    return ref.getDownloadURL();
  }

  Future<void> send({
    required String conversationId,
    required String recipientId,
    String? text,
    String type = 'text',
    String? mediaUrl,
    String? thumbnailUrl,
    Duration? duration,
  }) async {
    if (uid.isEmpty || recipientId.isEmpty) return;
    final body = (text ?? '').trim();
    if (body.isEmpty && mediaUrl == null) return;
    final convo = _db.collection('conversations').doc(conversationId);
    final message = convo.collection('messages').doc();
    final batch = _db.batch();
    batch.set(message, {
      'senderId': uid,
      'recipientId': recipientId,
      'text': body,
      'type': type,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'durationMs': duration?.inMilliseconds,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [uid],
      'reactions': <String, dynamic>{},
      'status': 'sent',
    });
    batch.set(convo, {
      'memberIds': [uid, recipientId],
      'lastMessage': type == 'text' ? body : 'Sent a $type',
      'lastSenderId': uid,
      'updatedAt': FieldValue.serverTimestamp(),
      'typing': {uid: false},
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> react({required String conversationId, required String messageId, required String emoji}) async {
    if (uid.isEmpty) return;
    final ref = _db.collection('conversations').doc(conversationId).collection('messages').doc(messageId);
    await ref.set({'reactions.$uid': emoji}, SetOptions(merge: true));
  }

  Future<void> markRead({required String conversationId, required String messageId}) async {
    if (uid.isEmpty) return;
    await _db.collection('conversations').doc(conversationId).collection('messages').doc(messageId)
        .update({'readBy': FieldValue.arrayUnion([uid]), 'status': 'read'});
  }

  Future<void> reportMessage({required String conversationId, required String messageId, required String reason}) async {
    if (uid.isEmpty) return;
    await _db.collection('message_reports').add({
      'reporterId': uid,
      'conversationId': conversationId,
      'messageId': messageId,
      'reason': reason,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> blockUser(String targetUid) async {
    if (uid.isEmpty || targetUid.isEmpty || uid == targetUid) return;
    await _db.collection('users').doc(uid).collection('blocks').doc(targetUid).set({
      'blockedUserId': targetUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
