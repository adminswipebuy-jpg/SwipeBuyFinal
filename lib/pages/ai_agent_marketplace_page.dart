import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/ai_agent_marketplace_service.dart';
import 'ai_agent_trust_page.dart';

class AiAgentMarketplacePage extends StatefulWidget {
  const AiAgentMarketplacePage({super.key});
  @override
  State<AiAgentMarketplacePage> createState() => _AiAgentMarketplacePageState();
}

class _AiAgentMarketplacePageState extends State<AiAgentMarketplacePage> {
  final _service = AiAgentMarketplaceService();
  String _category = 'All';
  bool _busy = false;
  final _categories = const ['All', 'Shopping', 'Jobs', 'Property', 'Travel', 'Business', 'Productivity', 'Discovery'];

  Future<void> _install(String id) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _service.installAgent(id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agent installed to your SwipeBuy AI workspace.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(String id) async {
    try {
      await _service.saveAgent(id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agent saved.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _publish() async {
    final title = TextEditingController();
    final description = TextEditingController();
    final steps = TextEditingController();
    String category = 'Productivity';
    final ok = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
      title: const Text('Publish an AI agent'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Agent name')),
        const SizedBox(height: 10),
        TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'What does it do?')),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: category, items: _categories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setLocal(() => category = v ?? category), decoration: const InputDecoration(labelText: 'Category')),
        const SizedBox(height: 10),
        TextField(controller: steps, maxLines: 4, decoration: const InputDecoration(labelText: 'Steps (one per line)')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Publish'))],
    )));
    if (ok != true) return;
    final cleanedSteps = steps.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (title.text.trim().isEmpty || description.text.trim().isEmpty || cleanedSteps.isEmpty) return;
    try {
      await _service.publishAgent(title: title.text, description: description.text, category: category, steps: cleanedSteps);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agent published to the marketplace.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI Agent Marketplace 2.0'), actions: [IconButton(onPressed: _publish, icon: const Icon(Icons.add_business_outlined))]),
    body: Column(children: [
      _hero(),
      SizedBox(height: 58, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), scrollDirection: Axis.horizontal, itemCount: _categories.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) {
        final c = _categories[i];
        return ChoiceChip(label: Text(c), selected: _category == c, onSelected: (_) => setState(() => _category = c));
      })),
      Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: _service.streamAgents(category: _category), builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) return const Center(child: Text('No published agents in this category yet.'));
        return ListView.builder(padding: const EdgeInsets.fromLTRB(16, 4, 16, 30), itemCount: docs.length, itemBuilder: (_, i) {
          final d = docs[i].data();
          final steps = (d['steps'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
          return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const CircleAvatar(child: Icon(Icons.smart_toy_outlined)), const SizedBox(width: 10), Expanded(child: Text(d['title']?.toString() ?? 'AI Agent', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), _tag(d['category']?.toString() ?? 'Discovery')]),
            const SizedBox(height: 8),
            Text(d['description']?.toString() ?? '', style: const TextStyle(color: Colors.white70, height: 1.35)),
            const SizedBox(height: 10),
            Text('${steps.length} steps • ${d['installCount'] ?? 0} installs • ${(d['rating'] ?? 0).toString()}★', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(spacing: 7, runSpacing: 7, children: steps.take(4).map((s) => Chip(label: Text(s, maxLines: 1, overflow: TextOverflow.ellipsis))).toList()),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: FilledButton.icon(onPressed: _busy ? null : () => _install(docs[i].id), icon: const Icon(Icons.download_outlined), label: const Text('Install'))), const SizedBox(width: 8), IconButton(onPressed: () => _save(docs[i].id), icon: const Icon(Icons.bookmark_border)), IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AiAgentTrustPage(agentId: docs[i].id))), icon: const Icon(Icons.verified_user_outlined))]),
          ])));
        });
      }))
    ]),
  );

  Widget _hero() => Container(margin: const EdgeInsets.fromLTRB(16, 12, 16, 4), padding: const EdgeInsets.all(18), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF16251F), Color(0xFF11161E)]), border: Border.all(color: Colors.white10)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Discover useful AI agents', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
    SizedBox(height: 7),
    Text('Install reusable task plans created for shopping, jobs, travel, business and more. Agents stay gated: real-world actions still require the appropriate confirmation and trusted backend processing.', style: TextStyle(color: Colors.white70, height: 1.35)),
  ]));

  Widget _tag(String label) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(.06), borderRadius: BorderRadius.circular(99)), child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)));
}
