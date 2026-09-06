import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class MarketingGrowthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _uid => AuthService.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> campaigns() {
    if (_uid.isEmpty) return const Stream.empty();
    return _db.collection('businessMarketingCampaigns')
        .where('businessId', isEqualTo: _uid)
        .limit(100)
        .snapshots();
  }

  Future<void> createCampaign({
    required String name,
    required String channel,
    required String objective,
    required String audience,
    required String budget,
  }) async {
    if (_uid.isEmpty) return;
    await _db.collection('businessMarketingCampaigns').add({
      'businessId': _uid,
      'name': name.trim(),
      'channel': channel,
      'objective': objective,
      'audience': audience,
      'budget': budget.trim(),
      'status': 'draft',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestPerformanceInsights() async {
    if (_uid.isEmpty) return;
    await _db.collection('businessMarketingInsightRequests').add({
      'businessId': _uid,
      'requestedAt': FieldValue.serverTimestamp(),
      'status': 'requested',
      'source': 'merchant_growth_dashboard',
    });
  }
}
