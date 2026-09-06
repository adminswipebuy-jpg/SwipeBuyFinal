import 'package:flutter/material.dart';
import '../services/ai_proactive_assistant_service.dart';

class AiProactiveAssistantPage extends StatefulWidget {
  const AiProactiveAssistantPage({super.key});
  @override
  State<AiProactiveAssistantPage> createState() => _AiProactiveAssistantPageState();
}

class _AiProactiveAssistantPageState extends State<AiProactiveAssistantPage> {
  final _service = AiProactiveAssistantService();
  final _title = TextEditingController();
  final _query = TextEditingController();
  final _category = TextEditingController();
  String _type = 'price_watch';
  String _cadence = 'daily';

  @override
  void dispose() { _title.dispose(); _query.dispose(); _category.dispose(); super.dispose(); }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    await _service.createAlert(
      title: title,
      type: _type,
      query: _query.text,
      category: _category.text,
      cadence: _cadence,
    );
    if (!mounted) return;
    _title.clear(); _query.clear(); _category.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Smart alert saved.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI Proactive Assistant 3.0')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      _hero(), const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Create a proactive AI alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('SwipeBuy can monitor opportunities and surface a reminder when a backend-verified event matches your request. Alerts never execute purchases or payments by themselves.', style: TextStyle(color: Colors.white60, height: 1.35)),
        const SizedBox(height: 14),
        TextField(controller: _title, decoration: const InputDecoration(labelText: 'Alert name', hintText: 'e.g. Find a better price for running shoes')),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: _type, items: const [
          DropdownMenuItem(value: 'price_watch', child: Text('Price watch')),
          DropdownMenuItem(value: 'job_match', child: Text('Job match')),
          DropdownMenuItem(value: 'property_match', child: Text('Property match')),
          DropdownMenuItem(value: 'deal_watch', child: Text('Deal watch')),
          DropdownMenuItem(value: 'event_reminder', child: Text('Event reminder')),
          DropdownMenuItem(value: 'content_digest', child: Text('Content digest')),
        ], onChanged: (v) => setState(() => _type = v ?? 'price_watch'), decoration: const InputDecoration(labelText: 'Alert type')),
        const SizedBox(height: 10),
        TextField(controller: _query, decoration: const InputDecoration(labelText: 'What should AI watch?', hintText: 'e.g. iPhone 15 under GH₵ 5000')),
        const SizedBox(height: 10),
        TextField(controller: _category, decoration: const InputDecoration(labelText: 'Category (optional)', hintText: 'Electronics, Jobs, Travel...')),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: _cadence, items: const [
          DropdownMenuItem(value: 'realtime', child: Text('As soon as available')),
          DropdownMenuItem(value: 'daily', child: Text('Daily')),
          DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
        ], onChanged: (v) => setState(() => _cadence = v ?? 'daily'), decoration: const InputDecoration(labelText: 'Cadence')),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.add_alert_outlined), label: const Text('Create smart alert'))),
      ]))),
      const SizedBox(height: 18),
      const Text('Your proactive alerts', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      StreamBuilder(builder: (context, snapshot) {
        final docs = (snapshot.data?.docs ?? []);
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
        if (docs.isEmpty) return const Card(child: ListTile(leading: Icon(Icons.notifications_active_outlined), title: Text('No smart alerts yet'), subtitle: Text('Create one above and let SwipeBuy monitor opportunities for you.')));
        return Column(children: docs.map((doc) {
          final d = doc.data();
          final status = d['status']?.toString() ?? 'active';
          return Card(child: ListTile(
            leading: CircleAvatar(child: Icon(status == 'active' ? Icons.notifications_active_outlined : Icons.pause_circle_outline)),
            title: Text(d['title']?.toString() ?? 'Smart alert', style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('${d['type'] ?? 'alert'} • ${d['cadence'] ?? 'daily'}${(d['query']?.toString().isNotEmpty ?? false) ? '\n${d['query']}' : ''}'),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(onSelected: (value) async {
              if (value == 'delete') await _service.deleteAlert(doc.id); else await _service.setStatus(doc.id, value);
            }, itemBuilder: (_) => [
              if (status == 'active') const PopupMenuItem(value: 'paused', child: Text('Pause')) else const PopupMenuItem(value: 'active', child: Text('Resume')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ]),
          ));
        }).toList());
      }, stream: _service.streamAlerts()),
    ]),
  );

  Widget _hero() => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [CircleAvatar(radius: 23, child: Icon(Icons.notifications_active_outlined)), SizedBox(width: 12), Expanded(child: Text('Proactive SwipeBuy AI', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)))]),
    SizedBox(height: 10),
    Text('Move from “ask when I need it” to “tell me when it matters”. Production triggers should be verified by trusted backend services before a user is notified.', style: TextStyle(color: Colors.white70, height: 1.4)),
  ]);
}
