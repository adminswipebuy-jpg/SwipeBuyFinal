import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class TeenWellbeingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _uid => AuthService.currentUser?.uid ?? '';

  DocumentReference<Map<String, dynamic>> get _ref =>
      _db.collection('wellbeing_profiles').doc(_uid);

  Stream<Map<String, dynamic>?> watchMine() {
    if (_uid.isEmpty) return const Stream.empty();
    return _ref.snapshots().map((doc) => doc.data());
  }

  Future<void> saveControls({
    required bool breakReminders,
    required bool saferRecommendations,
    required bool quietNotifications,
    required bool reducedSocialPressure,
  }) async {
    if (_uid.isEmpty) throw StateError('Sign in required.');
    await _ref.set({
      'breakReminders': breakReminders,
      'saferRecommendations': saferRecommendations,
      'quietNotifications': quietNotifications,
      'reducedSocialPressure': reducedSocialPressure,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> recordWellbeingAction(String action) async {
    if (_uid.isEmpty) throw StateError('Sign in required.');
    await _db.collection('wellbeing_events').add({
      'uid': _uid,
      'action': action,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestWellbeingReview(String reason) async {
    if (_uid.isEmpty) throw StateError('Sign in required.');
    await _db.collection('wellbeing_reviews').add({
      'uid': _uid,
      'reason': reason,
      'status': 'pending_backend_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
