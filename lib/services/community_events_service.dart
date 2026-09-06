import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Community events and fan-experience foundation.
/// Real ticketing, notifications and live-video entitlements should be enforced server-side.
class CommunityEventsService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> upcomingEvents() {
    return _db.collection('community_events')
        .where('status', isEqualTo: 'published')
        .orderBy('startAt')
        .limit(50)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> liveGroups() {
    return _db.collection('live_groups')
        .where('status', isEqualTo: 'live')
        .limit(50)
        .snapshots();
  }

  Stream<bool> isFollowingEvent(String eventId) {
    if (uid.isEmpty || eventId.isEmpty) return Stream<bool>.value(false);
    return _db.collection('event_followers').doc('${uid}_$eventId').snapshots().map((d) => d.exists);
  }

  Future<void> followEvent(String eventId) async {
    if (uid.isEmpty || eventId.isEmpty) return;
    await _db.collection('event_followers').doc('${uid}_$eventId').set({
      'userId': uid, 'eventId': eventId, 'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unfollowEvent(String eventId) async {
    if (uid.isEmpty || eventId.isEmpty) return;
    await _db.collection('event_followers').doc('${uid}_$eventId').delete();
  }

  Future<void> requestEventReminder(String eventId, {required String cadence}) async {
    if (uid.isEmpty || eventId.isEmpty) return;
    await _db.collection('event_reminders').doc('${uid}_$eventId').set({
      'userId': uid, 'eventId': eventId, 'cadence': cadence,
      'status': 'requested', 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> joinLiveGroup(String groupId) async {
    if (uid.isEmpty || groupId.isEmpty) return;
    await _db.collection('live_group_members').doc('${uid}_$groupId').set({
      'userId': uid, 'groupId': groupId, 'role': 'viewer',
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestFanExperience({required String creatorId, required String experienceType, required String note}) async {
    if (uid.isEmpty || creatorId.isEmpty || experienceType.trim().isEmpty) return;
    await _db.collection('fan_experience_requests').add({
      'requesterId': uid, 'creatorId': creatorId,
      'experienceType': experienceType.trim(), 'note': note.trim(),
      'status': 'pending', 'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
