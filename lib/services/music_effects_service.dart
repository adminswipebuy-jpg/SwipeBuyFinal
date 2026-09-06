import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MusicTrack {
  final String id;
  final String title;
  final String creator;
  final String category;
  final int durationSeconds;
  final bool original;
  final bool popular;

  const MusicTrack({required this.id, required this.title, required this.creator, required this.category, required this.durationSeconds, this.original = false, this.popular = false});

  Map<String, dynamic> toMap() => {
        'title': title,
        'creator': creator,
        'category': category,
        'durationSeconds': durationSeconds,
        'original': original,
        'popular': popular,
      };
}

class MusicEffectsService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  static const tracks = <MusicTrack>[
    MusicTrack(id: 'sb-afrobeat-01', title: 'Golden Hour', creator: 'SwipeBuy Sounds', category: 'Afrobeat', durationSeconds: 29, popular: true),
    MusicTrack(id: 'sb-highlife-01', title: 'Ghana Sunrise', creator: 'Kofi Beats', category: 'Highlife', durationSeconds: 31, popular: true),
    MusicTrack(id: 'sb-pop-01', title: 'Neon Nights', creator: 'SwipeBuy Sounds', category: 'Pop', durationSeconds: 24, popular: true),
    MusicTrack(id: 'sb-hiphop-01', title: 'Move Different', creator: 'Jae Motion', category: 'Hip-Hop', durationSeconds: 27),
    MusicTrack(id: 'sb-chill-01', title: 'Slow Sunday', creator: 'Luna Waves', category: 'Chill', durationSeconds: 36),
    MusicTrack(id: 'sb-original', title: 'Original sound', creator: 'You', category: 'Original', durationSeconds: 0, original: true),
  ];

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> favoritesStream() {
    if (uid.isEmpty) return const Stream.empty();
    return _db.collection('users').doc(uid).collection('saved_sounds').snapshots();
  }

  Future<void> toggleFavorite(MusicTrack track, bool saved) async {
    if (uid.isEmpty) throw StateError('You must be signed in.');
    final ref = _db.collection('users').doc(uid).collection('saved_sounds').doc(track.id);
    if (saved) {
      await ref.delete();
    } else {
      await ref.set({...track.toMap(), 'savedAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> saveEditPreset({required String musicId, required String effect, required String transition, required String stickerStyle, required String textAnimation}) async {
    if (uid.isEmpty) throw StateError('You must be signed in.');
    await _db.collection('creator_edit_presets').add({
      'creatorId': uid,
      'musicId': musicId,
      'effect': effect,
      'transition': transition,
      'stickerStyle': stickerStyle,
      'textAnimation': textAnimation,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
