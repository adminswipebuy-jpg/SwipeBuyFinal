import 'dart:async';

class FreelancerProfileDraft {
  final String headline;
  final String skills;
  final String portfolioUrl;
  final String availability;
  const FreelancerProfileDraft({required this.headline, required this.skills, required this.portfolioUrl, required this.availability});
}

class FreelancerMarketplaceService {
  FreelancerMarketplaceService._();
  static final instance = FreelancerMarketplaceService._();
  final _profiles = StreamController<FreelancerProfileDraft>.broadcast();
  Stream<FreelancerProfileDraft> get profiles => _profiles.stream;

  void publishProfile(FreelancerProfileDraft draft) {
    _profiles.add(draft);
  }

  /// Marketplace actions are drafts only until the user explicitly confirms
  /// and a trusted backend validates identity, eligibility and payment terms.
  Map<String, String> prepareProposal({required String project, required String pitch, required String budget}) => {
    'project': project,
    'pitch': pitch,
    'budget': budget,
    'status': 'draft_pending_user_confirmation',
  };
}
