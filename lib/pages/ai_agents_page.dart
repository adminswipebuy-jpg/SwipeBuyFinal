import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/ai_agent_service.dart';

class AiAgentsPage extends StatefulWidget {
  const AiAgentsPage({super.key});
  @override
  State<AiAgentsPage> createState() => _AiAgentsPageState();
}

class _AiAgentsPageState extends State<AiAgentsPage> {
  final _service = AiAgentService();
  final _goal = TextEditingController();
  AiAgentPlan? _plan;
  bool _busy = false;
  String? _createdRunId;

  @override
  void dispose() { _goal.dispose(); super.dispose(); }

  void _preview() {
    final text = _goal.text.trim();
    if (text.isEmpty) return;
    setState(() { _plan = _service.buildPlan(text); _createdRunId = null; });
  }

  Future<void> _create() async {
    final plan = _plan;
    if (plan == null || _busy) return;
    setState(() => _busy = true);
    try {
      final id = await _service.createRun(plan);
      if (mounted) {
        setState(() => _createdRunId = id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agent plan saved. It is not executing real-world actions yet.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _queue(String id) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _service.requestExecution(id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Execution request queued for trusted backend processing.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI Agents 2.0')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      _hero(),
      const SizedBox(height: 14),
      TextField(
        controller: _goal,
        minLines: 2,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'What should the agent accomplish?',
          hintText: 'Find a good phone under GHS 4,000, compare 5 options and prepare checkout',
          filled: true,
          prefixIcon: const Icon(Icons.auto_awesome),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: FilledButton.icon(onPressed: _preview, icon: const Icon(Icons.account_tree_outlined), label: const Text('Build plan'))),
      ]),
      if (_plan != null) ...[
        const SizedBox(height: 18),
        _planCard(_plan!),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: _busy ? null : _create, icon: const Icon(Icons.save_outlined), label: Text(_createdRunId == null ? 'Save agent task' : 'Saved')),
        if (_plan!.requiresConfirmation) const Padding(padding: EdgeInsets.only(top: 10), child: Text('Some actions can affect purchases, bookings or publishing. SwipeBuy requires explicit confirmation before sensitive actions.', style: TextStyle(color: Colors.amberAccent, height: 1.35))),
      ],
      const SizedBox(height: 26),
      const Text('Recent agent tasks', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.streamRuns(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) return const Card(child: ListTile(leading: Icon(Icons.smart_toy_outlined), title: Text('No agent tasks yet'), subtitle: Text('Build your first multi-step task above.')));
          return Column(children: docs.map((doc) {
            final d = doc.data();
            final status = d['status']?.toString() ?? 'planned';
            final steps = (d['steps'] as List?)?.length ?? 0;
            final queued = status == 'queued';
            return Card(margin: const EdgeInsets.only(bottom: 9), child: ListTile(
              leading: CircleAvatar(child: Icon(queued ? Icons.schedule : Icons.smart_toy_outlined)),
              title: Text(d['goal']?.toString() ?? 'Agent task', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${d['intent'] ?? 'Discovery'} • $steps steps • ${status.toUpperCase()}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'queue') await _queue(doc.id);
                  if (value == 'cancel') await _service.cancelRun(doc.id);
                },
                itemBuilder: (_) => [
                  if (!queued && status != 'cancelled') const PopupMenuItem(value: 'queue', child: Text('Request execution')),
                  if (status != 'cancelled') const PopupMenuItem(value: 'cancel', child: Text('Cancel task')),
                ],
              ),
            ));
          }).toList());
        },
      ),
    ]),
  );

  Widget _hero() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF16251E), Color(0xFF11161E)]), border: Border.all(color: Colors.white10)),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [CircleAvatar(radius: 23, child: Icon(Icons.smart_toy_outlined)), SizedBox(width: 12), Expanded(child: Text('Your multi-step AI agent', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)))]),
      SizedBox(height: 10),
      Text('Turn one goal into a sequence of smaller tasks. The app can save the plan and request trusted backend execution; real-world actions remain gated and are not claimed as completed by this client.', style: TextStyle(color: Colors.white70, height: 1.4)),
    ]),
  );

  Widget _planCard(AiAgentPlan plan) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [_pill(plan.intent, Icons.route_outlined), const SizedBox(width: 8), _pill('${plan.steps.length} steps', Icons.format_list_numbered)]),
    const SizedBox(height: 12),
    Text(plan.goal, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
    const SizedBox(height: 14),
    ...List.generate(plan.steps.length, (i) {
      final step = plan.steps[i];
      return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 15, child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(step.title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(step.description, style: const TextStyle(color: Colors.white60, height: 1.3))])),
      ]));
    }),
  ])));

  Widget _pill(String label, IconData icon) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .06), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white10)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label, style: const TextStyle(fontWeight: FontWeight.w700))]));
}
