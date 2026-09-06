
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final _db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> search(
    String query,
  ) async {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return [];
    // Firestore does not provide full-text search. This lightweight discovery
    // contract uses approved listings and local filtering; production should
    // connect Algolia/Typesense/Elastic/OpenSearch or a server-side index.
    final snap = await _db.collection('listings')
      .where('status', isEqualTo: 'published')
      .limit(300).get();

    return snap.docs.where((d) {
      final x = d.data();
      final text = '${x['title'] ?? ''} ${x['category'] ?? ''} '
          '${x['seller'] ?? ''} ${x['locationText'] ?? ''}'.toLowerCase();
      return text.contains(term);
    }).toList();
  }
}
