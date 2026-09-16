import 'package:flutter/material.dart';
import '../services/advanced_moderation_service.dart';

class AdvancedModerationPage extends StatefulWidget {
  const AdvancedModerationPage({super.key});
  @override
  State<AdvancedModerationPage> createState() => _AdvancedModerationPageState();
}

class _AdvancedModerationPageState extends State<AdvancedModerationPage> {
  final service = AdvancedModerationService();
  final targetId = TextEditingController();
  final reason = TextEditingController();
  String targetType = 'content';
  String signal = 'spam';
  bool busy = false;

  Future<void> _submitSignal() async {
    setState(() => busy = true);
    try {
      await service.submitSafetySignal(
        targetId: targetId.text,
        targetType: targetType,
        signal: signal,
        details: reason.text,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Safety signal submitted for backend review.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally { if (mounted) setState(() => busy = false); }
  }

  Future<void> _requestReview() async {
    setState(() => busy = true);
    try {
      await service.requestReview(targetId: targetId.text, reason: reason.text);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Safety review requested.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally { if (mounted) setState(() => busy = false); }
  }

  @override
  void dispose() { targetId.dispose(); reason.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI Safety & Abuse Prevention 2.0')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Card(child: ListTile(leading: Icon(Icons.shield_outlined), title: Text('Automated safety signals'), subtitle: Text('Flag spam, scams, harassment, harmful content or suspicious behavior for trusted moderation systems.'))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Create safety signal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        DropdownButtonFormField<String>(initialValue: targetType, items: const [
          DropdownMenuItem(value: 'content', child: Text('Content')),
          DropdownMenuItem(value: 'account', child: Text('Account')),
          DropdownMenuItem(value: 'seller', child: Text('Seller')),
          DropdownMenuItem(value: 'professional', child: Text('Professional')),
          DropdownMenuItem(value: 'agent', child: Text('AI agent')),
        ], onChanged: busy ? null : (v) => setState(() => targetType = v ?? 'content'), decoration: const InputDecoration(labelText: 'Target type')),
        DropdownButtonFormField<String>(initialValue: signal, items: const [
          DropdownMenuItem(value: 'spam', child: Text('Spam')),
          DropdownMenuItem(value: 'scam', child: Text('Scam / fraud')),
          DropdownMenuItem(value: 'harassment', child: Text('Harassment')),
          DropdownMenuItem(value: 'harmful', child: Text('Harmful content')),
          DropdownMenuItem(value: 'abuse', child: Text('Abusive behavior')),
          DropdownMenuItem(value: 'copyright', child: Text('Copyright concern')),
        ], onChanged: busy ? null : (v) => setState(() => signal = v ?? 'spam'), decoration: const InputDecoration(labelText: 'Safety signal')),
        TextField(controller: targetId, decoration: const InputDecoration(labelText: 'Target ID')),
        TextField(controller: reason, maxLines: 3, decoration: const InputDecoration(labelText: 'Details')),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: busy ? null : _submitSignal, icon: const Icon(Icons.flag_outlined), label: const Text('Submit safety signal')),
      ]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Request safety review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('Use this when an automated decision or safety restriction needs human review.'),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: busy ? null : _requestReview, icon: const Icon(Icons.support_agent_outlined), label: const Text('Request review')),
      ]))),
      const SizedBox(height: 12),
      const Card(child: ListTile(leading: Icon(Icons.security_outlined), title: Text('Safety principle'), subtitle: Text('The client submits signals and requests. Detection models, risk scores, restrictions, takedowns, appeals and enforcement must remain trusted backend/admin decisions.'))),
    ]),
  );
}
