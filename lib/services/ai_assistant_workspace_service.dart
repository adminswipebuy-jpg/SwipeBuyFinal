import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiAssistantHistoryItem {
  final String id;
  final String prompt;
  final String intent;
  final DateTime? createdAt;

  const AiAssistantHistoryItem({
    required this.id,
    required this.prompt,
    required this.intent,
    required this.createdAt,
  });
}

class AiAssistantWorkspaceService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  String detectIntent(String prompt) {
    final text = prompt.toLowerCase();
    if (RegExp(r'\b(buy|price|product|phone|deal|shop)\b').hasMatch(text)) return 'Shopping';
    if (RegExp(r'\b(job|work|hire|career|vacancy|remote)\b').hasMatch(text)) return 'Jobs';
    if (RegExp(r'\b(house|home|land|apartment|rent|property)\b').hasMatch(text)) return 'Property';
    if (RegExp(r'\b(hotel|travel|trip|flight|tour|vacation)\b').hasMatch(text)) return 'Travel';
    if (RegExp(r'\b(learn|course|school|study|education)\b').hasMatch(text)) return 'Education';
    if (RegExp(r'\b(football|sport|match|score|player|team)\b').hasMatch(text)) return 'Sports';
    if (RegExp(r'\b(forex|crypto|bitcoin|stock|investment|finance)\b').hasMatch(text)) return 'Finance';
    if (RegExp(r'\b(book|appointment|service|designer|developer|repair)\b').hasMatch(text)) return 'Services';
    return 'Discovery';
  }

  List<String> nextActions(String prompt) {
    final intent = detectIntent(prompt);
    switch (intent) {
      case 'Shopping': return ['Compare results', 'Show nearby sellers', 'Find better deals'];
      case 'Jobs': return ['Filter remote jobs', 'Filter by location', 'Save job search'];
      case 'Property': return ['Filter by price', 'Show nearby listings', 'Compare properties'];
      case 'Travel': return ['Find hotels', 'Show nearby options', 'Compare prices'];
      case 'Education': return ['Find beginner courses', 'Save learning plan', 'Show popular topics'];
      case 'Sports': return ['Show latest updates', 'Follow this topic', 'Find related content'];
      case 'Finance': return ['Show latest updates', 'Explain this simply', 'Save this topic'];
      case 'Services': return ['Show nearby professionals', 'Compare providers', 'Book a service'];
      default: return ['Explore recommendations', 'Search globally', 'Use Nearby'];
    }
  }

  Future<void> savePrompt(String prompt) async {
    if (uid.isEmpty || prompt.trim().isEmpty) return;
    try {
      await _db.collection('ai_assistant_history').add({
        'userId': uid,
        'prompt': prompt.trim(),
        'intent': detectIntent(prompt),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<List<AiAssistantHistoryItem>> recentHistory({int limit = 8}) async {
    if (uid.isEmpty) return const [];
    try {
      final snap = await _db.collection('ai_assistant_history')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((doc) {
        final data = doc.data();
        final ts = data['createdAt'];
        return AiAssistantHistoryItem(
          id: doc.id,
          prompt: data['prompt']?.toString() ?? '',
          intent: data['intent']?.toString() ?? 'Discovery',
          createdAt: ts is Timestamp ? ts.toDate() : null,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }
}
