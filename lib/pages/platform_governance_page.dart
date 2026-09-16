import 'package:flutter/material.dart';
import '../services/platform_governance_service.dart';

class PlatformGovernancePage extends StatefulWidget {
  const PlatformGovernancePage({super.key});
  @override
  State<PlatformGovernancePage> createState() => _PlatformGovernancePageState();
}

class _PlatformGovernancePageState extends State<PlatformGovernancePage> {
  final service = PlatformGovernanceService();
  final targetId = TextEditingController();
  final caseId = TextEditingController();
  final reason = TextEditingController();
  String targetType = 'content';
  bool busy = false;

  Future<void> _report() async {
    setState(() => busy = true);
    try {
      await service.submitReport(targetId: targetId.text, targetType: targetType, reason: reason.text);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Moderation report submitted.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally { if (mounted) setState(() => busy = false); }
  }

  Future<void> _appeal() async {
    setState(() => busy = true);
    try {
      await service.requestAppeal(caseId: caseId.text, reason: reason.text);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appeal submitted for backend review.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally { if (mounted) setState(() => busy = false); }
  }

  @override
  void dispose() { targetId.dispose(); caseId.dispose(); reason.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Platform Governance & Safety 1.0')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Card(child: ListTile(leading: Icon(Icons.shield_outlined), title: Text('Global safety control center'), subtitle: Text('Reports, appeals, moderation, enforcement and audit workflows across SwipeBuy.'))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Report content, account or marketplace activity', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(initialValue: targetType, items: const [
          DropdownMenuItem(value: 'content', child: Text('Content')),
          DropdownMenuItem(value: 'account', child: Text('Account')),
          DropdownMenuItem(value: 'seller', child: Text('Seller')),
          DropdownMenuItem(value: 'professional', child: Text('Professional')),
          DropdownMenuItem(value: 'agent', child: Text('AI agent')),
        ], onChanged: busy ? null : (v) => setState(() => targetType = v ?? 'content'), decoration: const InputDecoration(labelText: 'Target type')),
        TextField(controller: targetId, decoration: const InputDecoration(labelText: 'Target ID')),
        TextField(controller: reason, maxLines: 3, decoration: const InputDecoration(labelText: 'Reason')),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: busy ? null : _report, icon: const Icon(Icons.flag_outlined), label: const Text('Submit report')),
      ]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Appeal a moderation decision', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        TextField(controller: caseId, decoration: const InputDecoration(labelText: 'Case ID')),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: busy ? null : _appeal, icon: const Icon(Icons.gavel_outlined), label: const Text('Request appeal review')),
      ]))),
      const SizedBox(height: 12),
      const Card(child: ListTile(leading: Icon(Icons.admin_panel_settings_outlined), title: Text('Governance principle'), subtitle: Text('The client submits signals and requests. Trusted backend/admin systems must decide enforcement, account restrictions, content takedowns, appeals and audit outcomes.'))),
    ]),
  );
}
