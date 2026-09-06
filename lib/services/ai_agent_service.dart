import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiAgentStep {
  final String title;
  final String description;
  final String action;
  const AiAgentStep({required this.title, required this.description, required this.action});

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'action': action,
  };
}

class AiAgentPlan {
  final String goal;
  final String intent;
  final List<AiAgentStep> steps;
  final bool requiresConfirmation;

  const AiAgentPlan({required this.goal, required this.intent, required this.steps, required this.requiresConfirmation});
}

class AiAgentRun {
  final String id;
  final String goal;
  final String status;
  final DateTime? createdAt;
  final List<dynamic> steps;

  const AiAgentRun({required this.id, required this.goal, required this.status, required this.createdAt, required this.steps});
}

class AiAgentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  AiAgentPlan buildPlan(String goal) {
    final text = goal.toLowerCase().trim();
    final intent = _detectIntent(text);
    final sensitive = RegExp(r'\b(buy|purchase|pay|book|cancel|withdraw|send|transfer|post|publish)\b').hasMatch(text);
    final List<AiAgentStep> steps = switch (intent) {
      'Shopping' => const [
        AiAgentStep(title: 'Understand the request', description: 'Extract category, budget, location and preferences.', action: 'analyze_request'),
        AiAgentStep(title: 'Search SwipeBuy', description: 'Find matching products and sellers across the marketplace.', action: 'search_marketplace'),
        AiAgentStep(title: 'Compare options', description: 'Rank useful matches by relevance, value and reputation.', action: 'compare_results'),
        AiAgentStep(title: 'Prepare the next action', description: 'Create a checkout or contact-ready handoff without completing payment.', action: 'prepare_action'),
      ],
      'Jobs' => const [
        AiAgentStep(title: 'Understand your job goal', description: 'Extract role, location, work mode and preferences.', action: 'analyze_request'),
        AiAgentStep(title: 'Search jobs', description: 'Find matching jobs and gigs from SwipeBuy.', action: 'search_jobs'),
        AiAgentStep(title: 'Rank matches', description: 'Prioritize relevance, location, work mode and recency.', action: 'rank_jobs'),
        AiAgentStep(title: 'Prepare applications', description: 'Save selected jobs and prepare application handoffs.', action: 'prepare_action'),
      ],
      'Property' => const [
        AiAgentStep(title: 'Understand the property need', description: 'Extract budget, area, property type and intent.', action: 'analyze_request'),
        AiAgentStep(title: 'Search property', description: 'Find relevant property listings.', action: 'search_property'),
        AiAgentStep(title: 'Compare listings', description: 'Compare price, location and listing signals.', action: 'compare_results'),
        AiAgentStep(title: 'Prepare viewing/contact', description: 'Create the next-step handoff without sending anything automatically.', action: 'prepare_action'),
      ],
      'Travel' => const [
        AiAgentStep(title: 'Understand the trip', description: 'Extract destination, dates, budget and preferences.', action: 'analyze_request'),
        AiAgentStep(title: 'Find options', description: 'Search hotels, travel listings and useful experiences.', action: 'search_travel'),
        AiAgentStep(title: 'Compare options', description: 'Rank choices using value, rating and location signals.', action: 'compare_results'),
        AiAgentStep(title: 'Prepare booking', description: 'Prepare the booking handoff; final booking requires confirmation.', action: 'prepare_action'),
      ],
      _ => const [
        AiAgentStep(title: 'Understand the goal', description: 'Break the request into smaller tasks.', action: 'analyze_request'),
        AiAgentStep(title: 'Discover relevant data', description: 'Search SwipeBuy across the most useful categories.', action: 'global_discovery'),
        AiAgentStep(title: 'Synthesize results', description: 'Combine findings into a useful action plan.', action: 'synthesize'),
        AiAgentStep(title: 'Prepare next action', description: 'Stage a safe handoff for anything that requires user confirmation.', action: 'prepare_action'),
      ],
    };
    return AiAgentPlan(goal: goal.trim(), intent: intent, steps: steps, requiresConfirmation: sensitive);
  }

  Future<String> createRun(AiAgentPlan plan) async {
    final userId = uid;
    if (userId == null) throw StateError('Sign in to create an AI agent task.');
    final ref = await _db.collection('ai_agent_runs').add({
      'userId': userId,
      'goal': plan.goal,
      'intent': plan.intent,
      'status': 'planned',
      'requiresConfirmation': plan.requiresConfirmation,
      'steps': plan.steps.map((s) => s.toMap()).toList(),
      'currentStep': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> requestExecution(String runId) async {
    await _db.collection('ai_agent_runs').doc(runId).update({
      'status': 'queued',
      'executionRequested': true,
      'queuedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamRuns() {
    final userId = uid;
    if (userId == null) return const Stream.empty();
    return _db.collection('ai_agent_runs').where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).limit(20).snapshots();
  }

  Future<void> cancelRun(String id) async {
    await _db.collection('ai_agent_runs').doc(id).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _detectIntent(String text) {
    if (RegExp(r'\b(buy|phone|product|shop|deal|price)\b').hasMatch(text)) return 'Shopping';
    if (RegExp(r'\b(job|work|career|vacancy|remote|gig)\b').hasMatch(text)) return 'Jobs';
    if (RegExp(r'\b(house|home|land|apartment|rent|property)\b').hasMatch(text)) return 'Property';
    if (RegExp(r'\b(hotel|travel|trip|flight|tour|vacation)\b').hasMatch(text)) return 'Travel';
    if (RegExp(r'\b(course|school|study|learn|education)\b').hasMatch(text)) return 'Education';
    return 'Discovery';
  }
}
