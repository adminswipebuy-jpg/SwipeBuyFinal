import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MediaTranscodingService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> requestTranscode({required String mediaId, String profile = 'adaptive'}) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    if (mediaId.trim().isEmpty) throw ArgumentError('Media ID required');
    await db.collection('media_transcoding_requests').add({
      'uid': uid,
      'mediaId': mediaId.trim(),
      'profile': profile,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestThumbnail({required String mediaId, int count = 3}) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    await db.collection('media_thumbnail_requests').add({
      'uid': uid,
      'mediaId': mediaId.trim(),
      'count': count.clamp(1, 12),
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestPlaybackReview({required String mediaId, required String issue}) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    await db.collection('media_playback_reviews').add({
      'uid': uid,
      'mediaId': mediaId.trim(),
      'issue': issue.trim(),
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
