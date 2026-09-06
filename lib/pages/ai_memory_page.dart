import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ai_memory_service.dart';

class AiMemoryPage extends StatefulWidget {
  const AiMemoryPage({super.key});
  @override
  State<AiMemoryPage> createState() => _AiMemoryPageState();
}

class _AiMemoryPageState extends State<AiMemoryPage> {
  final _service = AiMemoryService();
  final _title = TextEditingController();
  final _value = TextEditingController();
  String _category = 'Preference';
  bool _busy = false;

  @override
  void dispose() { _title.dispose(); _value.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _value.text.trim().isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      await _service.saveMemory(title: _title.text, value: _value.text, category: _category);
      _title.clear(); _value.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI memory saved.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI Memory 2.0')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF18261F), Color(0xFF111720)]), border: Border.all(color: Colors.white10)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Give SwipeBuy useful context', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text('Save preferences you control, such as favourite categories, shopping habits or trip preferences. You can pause or delete any memory at any time.'),
        ]),
      ),
      const SizedBox(height: 16),
      TextField(controller: _title, decoration: const InputDecoration(labelText: 'Memory title', hintText: 'Favourite phone brand', filled: true)),
      const SizedBox(height: 10),
      TextField(controller: _value, maxLines: 3, decoration: const InputDecoration(labelText: 'What should SwipeBuy remember?', hintText: 'I usually prefer Samsung phones under GH₵2,500', filled: true)),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(value: _category, decoration: const InputDecoration(labelText: 'Category', filled: true), items: const ['Preference', 'Budget', 'Location', 'Interest', 'Travel', 'Shopping', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _category = v ?? _category)),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: _busy ? null : _save, icon: const Icon(Icons.save_outlined), label: Text(_busy ? 'Saving…' : 'Save memory')),
      const SizedBox(height: 24),
      const Text('Your AI memory', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.streamMemories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(22), child: CircularProgressIndicator()));
          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) return const Card(child: ListTile(leading: Icon(Icons.psychology_outlined), title: Text('No saved memories'), subtitle: Text('Add preferences that help personalize SwipeBuy.')));
          return Column(children: docs.map((doc) {
            final d = doc.data();
            final enabled = d['enabled'] == true;
            return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
              leading: CircleAvatar(child: Icon(enabled ? Icons.psychology : Icons.pause)),
              title: Text(d['title']?.toString() ?? 'Memory', style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${d['category'] ?? 'Preference'} • ${d['value'] ?? ''}', maxLines: 3, overflow: TextOverflow.ellipsis),
              trailing: PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'toggle') await _service.setEnabled(doc.id, !enabled);
                  if (action == 'delete') await _service.deleteMemory(doc.id);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'toggle', child: Text(enabled ? 'Pause memory' : 'Use memory')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ));
          }).toList());
        },
      ),
      const SizedBox(height: 16),
      const Card(child: ListTile(leading: Icon(Icons.lock_outline), title: Text('Privacy & control'), subtitle: Text('SwipeBuy should only use enabled memories. Sensitive actions still require explicit confirmation.'))),
    ]),
  );
}
