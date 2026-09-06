import 'dart:async';

class Opportunity {
  final String title;
  final String organization;
  final String type;
  final String location;
  final String summary;
  final int members;
  const Opportunity({required this.title, required this.organization, required this.type, required this.location, required this.summary, required this.members});
}

class ProfessionalNetworkService {
  ProfessionalNetworkService._();
  static final instance = ProfessionalNetworkService._();
  final _requests = StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get requests => _requests.stream;

  List<Opportunity> discover(String query) {
    final q = query.trim().toLowerCase();
    const all = [
      Opportunity(title: 'Flutter Builders Ghana', organization: 'SwipeBuy Community', type: 'Community', location: 'Ghana • Online', summary: 'Mobile builders, founders and product designers sharing practical opportunities.', members: 1820),
      Opportunity(title: 'Remote Product Designers', organization: 'Global Designers', type: 'Community', location: 'Global', summary: 'Portfolio reviews, client leads and design collaborations.', members: 960),
      Opportunity(title: 'Startup Founders Network', organization: 'West Africa', type: 'Networking', location: 'Accra • Online', summary: 'Meet founders, advisors, investors and talent for new ventures.', members: 2140),
      Opportunity(title: 'Freelance Growth Sprint', organization: 'SwipeBuy Pro', type: 'Opportunity', location: 'Global', summary: 'A project cohort connecting marketers with growing businesses.', members: 410),
    ];
    if (q.isEmpty) return all;
    return all.where((o) => '${o.title} ${o.organization} ${o.type} ${o.location} ${o.summary}'.toLowerCase().contains(q)).toList();
  }

  void requestJoin(Opportunity opportunity) => _requests.add({'title': opportunity.title, 'status': 'pending'});
}
