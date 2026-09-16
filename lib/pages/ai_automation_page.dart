import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ai_automation_service.dart';

class AiAutomationPage extends StatefulWidget {
  const AiAutomationPage({super.key});
  @override
  State<AiAutomationPage> createState() => _AiAutomationPageState();
}

class _AiAutomationPageState extends State<AiAutomationPage> {
  final _service = AiAutomationService();
  final _title = TextEditingController();
  final _instruction = TextEditingController();
  String _schedule = 'Every day';
  bool _busy = false;

  @override
  void dispose() { _title.dispose(); _instruction.dispose(); super.dispose(); }

  Future<void> _create() async {
    final title = _title.text.trim();
    final instruction = _instruction.text.trim();
    if (title.isEmpty || instruction.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      await _service.createTask(title: title, instruction: instruction, schedule: _schedule);
      _title.clear();
      _instruction.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Automation saved. Backend scheduling can now execute it.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI Automation 2.0')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF18261F), Color(0xFF111720)]), border: Border.all(color: Colors.white10)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Let SwipeBuy remember the routine', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text('Create repeatable AI routines such as daily deal checks, weekly job discovery or travel price monitoring. Execution remains controlled by the trusted backend.'),
        ]),
      ),
      const SizedBox(height: 16),
      TextField(controller: _title, decoration: const InputDecoration(labelText: 'Automation name', filled: true)),
      const SizedBox(height: 10),
      TextField(controller: _instruction, maxLines: 4, decoration: const InputDecoration(labelText: 'What should SwipeBuy do?', hintText: 'Find 5 new remote jobs in Ghana and notify me', filled: true)),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        initialValue: _schedule,
        decoration: const InputDecoration(labelText: 'Schedule', filled: true),
        items: ['Every day', 'Every week', 'Every month', 'When available'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
onChanged: (v) => setState(() => _schedule = v ?? 'Every day'),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: _busy ? null : _create, icon: const Icon(Icons.add_task), label: Text(_busy ? 'Saving…' : 'Save automation')),
      const SizedBox(height: 24),
      const Text('Your automations', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.streamTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(22), child: CircularProgressIndicator()));
          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) {
            return const Card(child: ListTile(leading: Icon(Icons.auto_awesome), title: Text('No automations yet'), subtitle: Text('Create your first routine above.')));
          }
          return Column(children: docs.map((doc) {
            final d = doc.data();
            final enabled = d['enabled'] == true;
            return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
              leading: CircleAvatar(child: Icon(enabled ? Icons.bolt : Icons.pause)),
              title: Text(d['title']?.toString() ?? 'Automation', style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${d['schedule'] ?? 'Schedule'} • ${d['instruction'] ?? ''}', maxLines: 3, overflow: TextOverflow.ellipsis),
              trailing: PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'toggle') await _service.setEnabled(doc.id, !enabled);
                  if (action == 'delete') await _service.deleteTask(doc.id);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'toggle', child: Text(enabled ? 'Pause' : 'Resume')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ));
          }).toList());
        },
      ),
    ]),
  );
}
