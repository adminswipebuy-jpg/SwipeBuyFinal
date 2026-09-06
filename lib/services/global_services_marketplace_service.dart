import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class GlobalServicesMarketplaceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> streamServices({String category = 'All'}) {
    Query<Map<String, dynamic>> q = _db.collection('professional_services').where('status', isEqualTo: 'published').limit(100);
    return q.snapshots().map((s) {
      final rows = s.docs.map((d) => {'id': d.id, ...d.data()}).where((r) => category == 'All' || (r['category'] ?? '') == category).toList();
      rows.sort((a, b) => ((b['rating'] ?? 0) as num).compareTo(((a['rating'] ?? 0) as num)));
      return rows;
    });
  }

  Future<void> publishService({required String title, required String category, required String startingPrice}) async {
    final user = AuthService.currentUser;
    if (user == null || title.isEmpty) return;
    await _db.collection('professional_services').add({
      'ownerId': user.uid,
      'providerName': user.displayName ?? 'SwipeBuy Professional',
      'title': title,
      'category': category,
      'startingPrice': startingPrice.isEmpty ? 'Quote' : startingPrice,
      'rating': 0,
      'location': 'Global',
      'verified': false,
      'status': 'pending_review',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createRequest({required String serviceId, required String kind}) async {
    final user = AuthService.currentUser;
    if (user == null) return;
    await _db.collection('professional_service_requests').add({
      'serviceId': serviceId,
      'requesterId': user.uid,
      'kind': kind,
      'status': 'pending_backend_confirmation',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
