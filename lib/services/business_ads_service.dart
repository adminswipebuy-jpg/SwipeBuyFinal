import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class BusinessAdsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _uid => AuthService.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> campaigns() {
    if (_uid.isEmpty) return const Stream.empty();
    return _db.collection('businessAdCampaigns').where('businessId', isEqualTo: _uid).snapshots();
  }

  Future<void> createDraft({
    required String name,
    required String objective,
    required String placement,
    required String audience,
    required String budget,
  }) async {
    if (_uid.isEmpty) return;
    await _db.collection('businessAdCampaigns').add({
      'businessId': _uid,
      'name': name.trim(),
      'objective': objective,
      'placement': placement,
      'audience': audience.trim(),
      'budget': budget.trim(),
      'status': 'draft',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestAdForecast() async {
    if (_uid.isEmpty) return;
    await _db.collection('businessAdForecastRequests').add({
      'businessId': _uid,
      'requestedAt': FieldValue.serverTimestamp(),
      'status': 'requested',
      'source': 'business_ads_platform',
    });
  }

  Future<void> requestLaunch(String campaignId) async {
    if (_uid.isEmpty || campaignId.trim().isEmpty) return;
    await _db.collection('businessAdLaunchRequests').add({
      'businessId': _uid,
      'campaignId': campaignId,
      'requestedAt': FieldValue.serverTimestamp(),
      'status': 'pending_backend_review',
      'source': 'business_ads_platform',
    });
  }
}
