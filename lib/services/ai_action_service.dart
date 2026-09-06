import 'package:cloud_functions/cloud_functions.dart';

class AiActionPlan {
  final String action;
  final String title;
  final String description;
  final Map<String, dynamic> parameters;
  final bool requiresConfirmation;

  const AiActionPlan({
    required this.action,
    required this.title,
    required this.description,
    required this.parameters,
    this.requiresConfirmation = true,
  });
}

class AiActionService {
  AiActionPlan plan(String prompt) {
    final text = prompt.trim().toLowerCase();
    if (RegExp(r'\b(buy|purchase|order)\b').hasMatch(text)) {
      return AiActionPlan(
        action: 'search_and_prepare_purchase',
        title: 'Prepare a purchase',
        description: 'Search matching products and prepare checkout. Payment still requires your confirmation.',
        parameters: {'query': prompt},
      );
    }
    if (RegExp(r'\b(book|reserve|hotel)\b').hasMatch(text)) {
      return AiActionPlan(
        action: 'search_and_prepare_booking',
        title: 'Prepare a booking',
        description: 'Find matching travel or service options and prepare a booking request.',
        parameters: {'query': prompt},
      );
    }
    if (RegExp(r'\b(apply|job|jobs)\b').hasMatch(text)) {
      return AiActionPlan(
        action: 'search_jobs',
        title: 'Find matching jobs',
        description: 'Search jobs that match your request. Applying will require your confirmation.',
        parameters: {'query': prompt},
      );
    }
    if (RegExp(r'\b(hire|freelancer|professional)\b').hasMatch(text)) {
      return AiActionPlan(
        action: 'search_professionals',
        title: 'Find a professional',
        description: 'Search verified professionals and present suitable candidates.',
        parameters: {'query': prompt},
      );
    }
    if (RegExp(r'\b(alert|notify|remind)\b').hasMatch(text)) {
      return AiActionPlan(
        action: 'create_alert',
        title: 'Create an alert',
        description: 'Create a notification for the requested topic or condition.',
        parameters: {'query': prompt},
      );
    }
    return AiActionPlan(
      action: 'search_and_explain',
      title: 'Search SwipeBuy',
      description: 'Search the SwipeBuy ecosystem and explain the best matches.',
      parameters: {'query': prompt},
    );
  }

  Future<Map<String, dynamic>> executeConfirmed(AiActionPlan plan) async {
    final callable = FirebaseFunctions.instance.httpsCallable('executeSwipeBuyAiAction');
    final result = await callable.call({
      'action': plan.action,
      'parameters': plan.parameters,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }
}
