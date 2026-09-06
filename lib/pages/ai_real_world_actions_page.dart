import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/ai_real_world_action_service.dart';

class AiRealWorldActionsPage extends StatefulWidget {
  const AiRealWorldActionsPage({super.key});
  @override
  State<AiRealWorldActionsPage> createState() => _AiRealWorldActionsPageState();
}

class _AiRealWorldActionsPageState extends State<AiRealWorldActionsPage> {
  final _service = AiRealWorldActionService();
  final _prompt = TextEditingController();
  AiRealWorldAction? _action;
  String? _requestId;
  bool _busy = false;

  @override
  void dispose() { _prompt.dispose(); super.dispose(); }

  void _preview() {
    final text = _prompt.text.trim();
    if (text.isEmpty) return;
    setState(() { _action = _service.buildAction(text); _requestId = null; });
  }

  Future<void> _stage() async {
    final action = _action;
    if (action == null || _busy) return;
    setState(() => _busy = true);
    try {
      final id = await _service.createRequest(action);
      if (mounted) {
        setState(() => _requestId = id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action staged. Nothing has been purchased, booked or sent.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _confirm(String id) async {
    if (_busy) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm AI action'),
        content: const Text('This only confirms the request for trusted backend processing. The client does not claim payment, booking, sending or submission has completed.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm'))],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await _service.confirm(id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Confirmed for trusted backend processing.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _cancel(String id) async {
    try { await _service.cancel(id); } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI Real-World Actions 3.0')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      _hero(),
      const SizedBox(height: 14),
      TextField(controller: _prompt, minLines: 2, maxLines: 4, decoration: InputDecoration(
        labelText: 'What should SwipeBuy prepare?',
        hintText: 'Prepare checkout for the best phone under GH₵ 4,000',
        filled: true, prefixIcon: const Icon(Icons.auto_awesome),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      )),
      const SizedBox(height: 10),
      FilledButton.icon(onPressed: _preview, icon: const Icon(Icons.auto_fix_high_outlined), label: const Text('Build action')),
      if (_action != null) ...[
        const SizedBox(height: 16), _actionCard(_action!),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: _busy ? null : _stage, icon: const Icon(Icons.playlist_add_check_outlined), label: Text(_requestId == null ? 'Stage action' : 'Staged')),
      ],
      const SizedBox(height: 24),
      const Text('Action requests', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: _service.streamRequests(), builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) return const Card(child: ListTile(leading: Icon(Icons.bolt_outlined), title: Text('No staged actions yet'), subtitle: Text('Create an action above to prepare a safe handoff.')));
        return Column(children: docs.map((doc) {
          final d = doc.data(); final status = d['status']?.toString() ?? 'staged';
          final requires = d['requiresConfirmation'] == true;
          return Card(margin: const EdgeInsets.only(bottom: 9), child: ListTile(
            leading: CircleAvatar(child: Icon(status == 'confirmed' ? Icons.verified_outlined : Icons.bolt_outlined)),
            title: Text(d['title']?.toString() ?? 'AI action', style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('${d['description'] ?? ''}\nSTATUS: ${status.toUpperCase()}', maxLines: 3, overflow: TextOverflow.ellipsis),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) { if (value == 'confirm') _confirm(doc.id); if (value == 'cancel') _cancel(doc.id); },
              itemBuilder: (_) => [
                if (requires && status == 'staged') const PopupMenuItem(value: 'confirm', child: Text('Confirm')),
                if (status != 'cancelled' && status != 'completed') const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
              ],
            ),
          ));
        }).toList());
      }),
    ]),
  );

  Widget _hero() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF18221E), Color(0xFF10151C)]), border: Border.all(color: Colors.white10)),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [CircleAvatar(radius: 23, child: Icon(Icons.bolt_outlined)), SizedBox(width: 12), Expanded(child: Text('AI actions with control', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)))]),
      SizedBox(height: 10),
      Text('SwipeBuy can prepare real-world actions such as checkout, booking or job applications, but the client never claims those actions are complete. Sensitive actions stay behind explicit confirmation and trusted backend processing.', style: TextStyle(color: Colors.white70, height: 1.4)),
    ]),
  );

  Widget _actionCard(AiRealWorldAction action) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const Icon(Icons.auto_awesome), const SizedBox(width: 8), Expanded(child: Text(action.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)))]),
    const SizedBox(height: 8), Text(action.description, style: const TextStyle(color: Colors.white70, height: 1.35)),
    const SizedBox(height: 10), Wrap(spacing: 8, children: [
      _pill(action.type), _pill(action.requiresConfirmation ? 'Confirmation required' : 'Low-risk save'),
    ]),
  ])));

  Widget _pill(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: Colors.white.withOpacity(.06), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white10)), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)));
}
