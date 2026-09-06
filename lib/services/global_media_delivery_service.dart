import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class GlobalMediaDeliveryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get uid => AuthService.currentUser?.uid ?? 'anonymous';

  Future<void> savePreferences({required String mode, required String region, required bool wifiOnly, required bool preload}) async {
    if (uid == 'anonymous') return;
    await _db.collection('media_delivery_preferences').doc(uid).set({
      'mode': mode, 'region': region, 'wifiOnly': wifiOnly, 'preload': preload,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> request(String type) async {
    if (uid == 'anonymous') return;
    await _db.collection('platform_media_requests').add({
      'uid': uid, 'type': type, 'status': 'requested', 'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
