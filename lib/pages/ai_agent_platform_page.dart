import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/ai_agent_marketplace_service.dart';
import '../services/ai_agent_monetization_service.dart';
import '../services/ai_agent_platform_service.dart';
import 'ai_agent_marketplace_page.dart';
import 'ai_agent_trust_page.dart';

class AiAgentPlatformPage extends StatefulWidget {
  const AiAgentPlatformPage({super.key});
  @override
  State<AiAgentPlatformPage> createState() => _AiAgentPlatformPageState();
}

class _AiAgentPlatformPageState extends State<AiAgentPlatformPage> {
  final _platform = AiAgentPlatformService();
  final _marketplace = AiAgentMarketplaceService();
  final _economy = AiAgentMonetizationService();

  Future<void> _open(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Future<void> _seedDemoAgent() async {
    try {
      await _marketplace.publishAgent(
        title: 'Global Shopping Scout',
        description: 'Finds products across supported SwipeBuy categories and prepares a shortlist for review.',
        category: 'Shopping',
        steps: const ['Understand request', 'Search marketplace', 'Compare options', 'Prepare shortlist'],
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Starter agent published to your marketplace.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Global AI Agent Platform 1.0'), actions: [
      IconButton(onPressed: () => _open(const AiAgentMarketplacePage()), icon: const Icon(Icons.storefront_outlined)),
      IconButton(onPressed: () => _open(const AiAgentTrustPage()), icon: const Icon(Icons.verified_user_outlined)),
    ]),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
      _hero(),
      const SizedBox(height: 14),
      _quickActions(),
      const SizedBox(height: 18),
      _sectionTitle('Installed agents', Icons.smart_toy_outlined),
      _installed(),
      const SizedBox(height: 18),
      _sectionTitle('My published agents', Icons.publish_outlined),
      _published(),
      const SizedBox(height: 18),
      _sectionTitle('Agent economy', Icons.account_balance_wallet_outlined),
      _economyCard(),
      const SizedBox(height: 18),
      _sectionTitle('Platform principles', Icons.shield_outlined),
      _principles(),
    ]),
  );

  Widget _hero() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: const LinearGradient(colors: [Color(0xFF173026), Color(0xFF11161E)]), border: Border.all(color: Colors.white10)),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('One AI platform. Many useful agents.', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      SizedBox(height: 8),
      Text('SwipeBuy brings discovery, agent creation, trust, usage and the agent economy into one workspace. Real-world actions remain confirmation-gated and backend-controlled.', style: TextStyle(color: Colors.white70, height: 1.35)),
    ]),
  );

  Widget _quickActions() => Wrap(spacing: 9, runSpacing: 9, children: [
    ActionChip(avatar: const Icon(Icons.storefront_outlined, size: 18), label: const Text('Marketplace'), onPressed: () => _open(const AiAgentMarketplacePage())),
    ActionChip(avatar: const Icon(Icons.verified_outlined, size: 18), label: const Text('Trust & Safety'), onPressed: () => _open(const AiAgentTrustPage())),
    ActionChip(avatar: const Icon(Icons.add_circle_outline, size: 18), label: const Text('Publish starter'), onPressed: _seedDemoAgent),
  ]);

  Widget _installed() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: _platform.streamInstalledAgents(), builder: (context, snap) {
    if (snap.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
    final docs = snap.data?.docs ?? const [];
    if (docs.isEmpty) return _empty('Install agents from the marketplace to build your AI workspace.');
    return Column(children: docs.take(8).map((doc) => _agentTile(doc.data(), installed: true)).toList());
  });

  Widget _published() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: _platform.streamMyAgents(), builder: (context, snap) {
    if (snap.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
    final docs = snap.data?.docs ?? const [];
    if (docs.isEmpty) return _empty('Publish reusable agents and build your own AI product portfolio.');
    return Column(children: docs.take(8).map((doc) => _agentTile(doc.data(), installed: false)).toList());
  });

  Widget _agentTile(Map<String, dynamic> data, {required bool installed}) {
    final title = data['title']?.toString() ?? data['agentId']?.toString() ?? 'AI Agent';
    final description = data['description']?.toString() ?? 'Reusable SwipeBuy agent';
    final agentId = data['agentId']?.toString() ?? data['id']?.toString() ?? '';
    return Card(margin: const EdgeInsets.only(bottom: 9), child: ListTile(
      leading: CircleAvatar(child: Icon(installed ? Icons.play_arrow_outlined : Icons.smart_toy_outlined)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: agentId.isEmpty ? null : IconButton(onPressed: () => _platform.createUsageEvent(agentId: agentId, action: 'open'), icon: const Icon(Icons.chevron_right)),
    ));
  }

  Widget _economyCard() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: _economy.streamMyAgentEarnings(), builder: (context, snap) {
    var total = 0.0;
    for (final d in snap.data?.docs ?? const []) {
      final v = d.data()['amount'];
      if (v is num) total += v.toDouble();
    }
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      const CircleAvatar(radius: 24, child: Icon(Icons.auto_awesome)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Creator earnings', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text('Recorded platform earnings: ${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
      ])),
      IconButton(onPressed: () => _open(const AiAgentMarketplacePage()), icon: const Icon(Icons.arrow_forward_ios, size: 18)),
    ])));
  });

  Widget _principles() => Column(children: const [
    ListTile(leading: Icon(Icons.lock_outline), title: Text('User-owned agent data'), subtitle: Text('Installed agents and usage events are scoped to the signed-in account.')),
    ListTile(leading: Icon(Icons.rule_outlined), title: Text('Confirmation before sensitive actions'), subtitle: Text('Payments, purchases, bookings and other impactful actions must be explicitly confirmed.')),
    ListTile(leading: Icon(Icons.admin_panel_settings_outlined), title: Text('Backend-controlled trust'), subtitle: Text('Ratings, enforcement, payments and execution should be verified by trusted backend services.')),
  ]);

  Widget _sectionTitle(String title, IconData icon) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))]));
  Widget _empty(String message) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(message, style: const TextStyle(color: Colors.white70))));
}
