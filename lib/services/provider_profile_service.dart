
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProviderProfileService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<void> saveProfile({
    required String displayName,
    required String businessType,
    required String bio,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    await _db.collection('users').doc(uid).set({
      'displayName': displayName.trim(),
      'businessType': businessType,
      'bio': bio.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'location': GeoPoint(latitude, longitude),
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String,dynamic>>> profile() {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> saveHours(Map<String, Map<String, dynamic>> hours) async {
    await _db.collection('users').doc(uid).collection('settings').doc('hours')
      .set({'hours': hours, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> saveServices(List<Map<String, dynamic>> items) async {
    await _db.collection('users').doc(uid).collection('settings').doc('services')
      .set({'items': items, 'updatedAt': FieldValue.serverTimestamp()});
  }
}
