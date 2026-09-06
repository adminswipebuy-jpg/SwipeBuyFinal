import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContentCreationStudioService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Future<String> saveDraft({
    required String category,
    required String caption,
    required String mediaUrl,
    required String mediaType,
    String? coverUrl,
    String? music,
    double trimStart = 0,
    double trimEnd = 60,
    bool autoCaptions = false,
    List<Map<String, dynamic>> overlays = const [],
  }) async {
    if (uid.isEmpty) throw StateError('You must be signed in.');
    final ref = _db.collection('creator_drafts').doc();
    await ref.set({
      'creatorId': uid,
      'category': category,
      'caption': caption.trim(),
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'coverUrl': coverUrl,
      'music': music,
      'trimStart': trimStart,
      'trimEnd': trimEnd,
      'autoCaptions': autoCaptions,
      'overlays': overlays,
      'status': 'draft',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<String> publishVideo({
    required String category,
    required String caption,
    required String mediaUrl,
    String? coverUrl,
    String? music,
    double trimStart = 0,
    double trimEnd = 60,
    bool autoCaptions = false,
    List<Map<String, dynamic>> overlays = const [],
  }) async {
    if (uid.isEmpty) throw StateError('You must be signed in.');
    final user = _auth.currentUser!;
    final ref = _db.collection('content').doc();
    await ref.set({
      'creatorId': uid,
      'creator': user.displayName?.trim().isNotEmpty == true ? user.displayName : 'SwipeBuy Creator',
      'category': category,
      'caption': caption.trim(),
      'mediaUrl': mediaUrl,
      'mediaType': 'video',
      'coverUrl': coverUrl,
      'music': music,
      'trimStart': trimStart,
      'trimEnd': trimEnd,
      'autoCaptions': autoCaptions,
      'overlays': overlays,
      'status': 'published',
      'views': 0,
      'likes': 0,
      'comments': 0,
      'shares': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
