import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RealtimePresenceService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get uid => auth.currentUser?.uid ?? '';

  Future<void> setPresence({required String status}) async {
    if (uid.isEmpty) throw StateError('Not signed in');
    final normalized = {'online', 'away', 'offline'}.contains(status) ? status : 'online';
    await db.collection('presence').doc(uid).set({
      'uid': uid,
      'status': normalized,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchPresence(String userId) {
    return db.collection('presence').doc(userId).snapshots();
  }

  Future<void> heartbeat() => setPresence(status: 'online');
  Future<void> goAway() => setPresence(status: 'away');
  Future<void> goOffline() => setPresence(status: 'offline');

  Future<void> setTyping({required String conversationId, required bool typing}) async {
    if (uid.isEmpty || conversationId.isEmpty) return;
    await db.collection('conversations').doc(conversationId).collection('typing').doc(uid).set({
      'uid': uid,
      'typing': typing,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchTyping(String conversationId) {
    return db.collection('conversations').doc(conversationId).collection('typing').snapshots();
  }
}
