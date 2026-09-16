import 'package:flutter/material.dart';
import '../services/freelancer_marketplace_service.dart';

class FreelancerMarketplacePage extends StatefulWidget {
  const FreelancerMarketplacePage({super.key});
  @override
  State<FreelancerMarketplacePage> createState() => _FreelancerMarketplacePageState();
}

class _FreelancerMarketplacePageState extends State<FreelancerMarketplacePage> {
  final headline = TextEditingController();
  final skills = TextEditingController();
  final portfolio = TextEditingController();
  final project = TextEditingController();
  final pitch = TextEditingController();
  final budget = TextEditingController();
  String availability = 'Available';
  String status = 'Create a professional profile, showcase your work, and prepare proposals.';

  @override
  void dispose() { for (final c in [headline, skills, portfolio, project, pitch, budget]) {
    c.dispose();
  } super.dispose(); }

  void _publish() {
    FreelancerMarketplaceService.instance.publishProfile(FreelancerProfileDraft(
      headline: headline.text.trim(), skills: skills.text.trim(), portfolioUrl: portfolio.text.trim(), availability: availability,
    ));
    setState(() => status = 'Profile draft published to your private workspace. Public visibility should be enabled only after backend validation.');
  }

  void _proposal() {
    final draft = FreelancerMarketplaceService.instance.prepareProposal(project: project.text.trim(), pitch: pitch.text.trim(), budget: budget.text.trim());
    setState(() => status = 'Proposal prepared for ${draft['project'].toString().isEmpty ? 'a project' : draft['project']}. Status: ${draft['status']}');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Professional Profiles & Freelancers 2.0')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Build. Showcase. Get hired.', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      const Text('Create a professional identity, portfolio and freelancer proposals inside SwipeBuy.', style: TextStyle(color: Colors.white60)),
      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Professional profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        _field(headline, 'Professional headline', 'e.g. Mobile Developer • Flutter'),
        const SizedBox(height: 10), _field(skills, 'Skills', 'Flutter, Firebase, UI/UX...'),
        const SizedBox(height: 10), _field(portfolio, 'Portfolio link', 'Optional public portfolio URL'),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(initialValue: availability, decoration: const InputDecoration(labelText: 'Availability', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'Available', child: Text('Available')), DropdownMenuItem(value: 'Open to offers', child: Text('Open to offers')), DropdownMenuItem(value: 'Busy', child: Text('Busy'))], onChanged: (v) => setState(() => availability = v ?? availability)),
        const SizedBox(height: 10), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _publish, icon: const Icon(Icons.badge_outlined), label: const Text('Save professional profile'))),
      ]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Portfolio & proof of work', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Use portfolio links, verified project history, reviews and completed-work evidence to build trust. Public verification should be performed by trusted backend services.', style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 10),
        const Wrap(spacing: 8, runSpacing: 8, children: [Chip(label: Text('Projects')), Chip(label: Text('Case studies')), Chip(label: Text('Certificates')), Chip(label: Text('Reviews'))]),
      ]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Freelancer proposal assistant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10), _field(project, 'Project title', 'What are you applying for?'),
        const SizedBox(height: 10), _field(pitch, 'Proposal / pitch', 'Explain your approach and relevant experience', lines: 5),
        const SizedBox(height: 10), _field(budget, 'Proposed budget', 'e.g. \$250 fixed or \$20/hour'),
        const SizedBox(height: 10), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _proposal, icon: const Icon(Icons.send_outlined), label: const Text('Prepare proposal'))),
      ]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(status))),
      const SizedBox(height: 18),
      const Text('Safety: hiring, contracts, identity checks, payments and external submissions must use explicit user confirmation and trusted backend/provider controls.', style: TextStyle(color: Colors.white54, fontSize: 12)),
    ]),
  );

  Widget _field(TextEditingController c, String label, String hint, {int lines = 1}) => TextField(controller: c, maxLines: lines, decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()));
}
