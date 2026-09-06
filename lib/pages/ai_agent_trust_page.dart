import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/ai_agent_marketplace_service.dart';
import '../services/ai_agent_trust_service.dart';

class AiAgentTrustPage extends StatefulWidget {
  const AiAgentTrustPage({super.key, this.agentId});
  final String? agentId;

  @override
  State<AiAgentTrustPage> createState() => _AiAgentTrustPageState();
}

class _AiAgentTrustPageState extends State<AiAgentTrustPage> {
  final trust = AiAgentTrustService();
  final marketplace = AiAgentMarketplaceService();
  String? selectedAgent;

  @override
  void initState() {
    super.initState();
    selectedAgent = widget.agentId;
  }

  Future<void> _review(String agentId) async {
    int rating = 5;
    final comment = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
      title: const Text('Rate this AI agent'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<int>(value: rating, items: [1,2,3,4,5].map((v) => DropdownMenuItem(value: v, child: Text('$v / 5 stars'))).toList(), onChanged: (v) => setLocal(() => rating = v ?? rating), decoration: const InputDecoration(labelText: 'Rating')),
        const SizedBox(height: 10),
        TextField(controller: comment, maxLines: 4, decoration: const InputDecoration(labelText: 'Review', hintText: 'How did the agent perform?')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit'))],
    )));
    if (ok != true) return;
    try {
      await trust.submitReview(agentId: agentId, rating: rating, comment: comment.text);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted for moderation.')));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  Future<void> _report(String agentId) async {
    String reason = 'Unsafe or harmful';
    final details = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
      title: const Text('Report AI agent'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(value: reason, items: const ['Unsafe or harmful','Scam or fraud','Privacy concern','Spam or misleading','Copyright or impersonation','Other'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setLocal(() => reason = v ?? reason), decoration: const InputDecoration(labelText: 'Reason')),
        const SizedBox(height: 10),
        TextField(controller: details, maxLines: 4, decoration: const InputDecoration(labelText: 'Details (optional)')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Report'))],
    )));
    if (ok != true) return;
    try {
      await trust.reportAgent(agentId: agentId, reason: reason, details: details.text);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted.')));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  Future<void> _safetySignal(String agentId, String signal) async {
    try {
      await trust.flagInstalledAgent(agentId: agentId, signal: signal);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(signal == 'safe' ? 'Marked as trusted for your workspace.' : 'Agent flagged for extra caution.')));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI Agent Trust & Safety 2.0')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      _hero(),
      const SizedBox(height: 12),
      if (selectedAgent != null) _reviewPanel(selectedAgent!),
      const SizedBox(height: 14),
      const Text('Trust principles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Reviews are signals, not guarantees.', style: TextStyle(fontWeight: FontWeight.w900)),
        SizedBox(height: 6), Text('Published agents should stay within SwipeBuy policies. Sensitive or real-world actions must remain confirmation-gated and should be executed by trusted backend services.', style: TextStyle(color: Colors.white70, height: 1.4)),
      ]))),
      const SizedBox(height: 14),
      const Text('Browse agents to review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: marketplace.streamAgents(), builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        final docs = snap.data?.docs ?? const [];
        if (docs.isEmpty) return const Card(child: ListTile(title: Text('No agents available yet.')));
        return Column(children: docs.take(20).map((d) { final m = d.data(); return Card(child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.smart_toy_outlined)),
          title: Text(m['title']?.toString() ?? 'AI Agent'),
          subtitle: Text('${m['category'] ?? 'Discovery'} • ${(m['rating'] ?? 0).toString()}★ • ${m['reviewCount'] ?? 0} reviews'),
          onTap: () => setState(() => selectedAgent = d.id),
        )); }).toList());
      }),
    ]),
  );

  Widget _hero() => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF182D25), Color(0xFF121720)]), border: Border.all(color: Colors.white10)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Safer AI agents', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
    SizedBox(height: 7),
    Text('See community feedback, flag risky agents and keep your AI workspace under your control.', style: TextStyle(color: Colors.white70, height: 1.35)),
  ]));

  Widget _reviewPanel(String agentId) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: trust.streamReviews(agentId), builder: (context, snap) {
    final docs = snap.data?.docs ?? const [];
    return Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Agent trust signals', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      Text('${docs.length} visible review${docs.length == 1 ? '' : 's'}', style: const TextStyle(color: Colors.white54)),
      const SizedBox(height: 10),
      if (docs.isEmpty) const Text('No community reviews yet. Be one of the first.'),
      for (final d in docs.take(8)) Padding(padding: const EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.star_rounded), title: Text('${d['rating'] ?? 0}/5'), subtitle: Text(d['comment']?.toString() ?? ''))),
      Wrap(spacing: 8, runSpacing: 8, children: [
        OutlinedButton.icon(onPressed: () => _review(agentId), icon: const Icon(Icons.rate_review_outlined), label: const Text('Write review')),
        OutlinedButton.icon(onPressed: () => _report(agentId), icon: const Icon(Icons.flag_outlined), label: const Text('Report')),
        OutlinedButton.icon(onPressed: () => _safetySignal(agentId, 'safe'), icon: const Icon(Icons.verified_outlined), label: const Text('Trust')),
        OutlinedButton.icon(onPressed: () => _safetySignal(agentId, 'caution'), icon: const Icon(Icons.warning_amber_outlined), label: const Text('Use caution')),
      ]),
    ])));
  });
}
