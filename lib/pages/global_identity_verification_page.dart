import 'package:flutter/material.dart';
import '../services/global_identity_verification_service.dart';

class GlobalIdentityVerificationPage extends StatefulWidget {
  const GlobalIdentityVerificationPage({super.key});
  @override
  State<GlobalIdentityVerificationPage> createState() => _GlobalIdentityVerificationPageState();
}

class _GlobalIdentityVerificationPageState extends State<GlobalIdentityVerificationPage> {
  final service = GlobalIdentityVerificationService();
  final name = TextEditingController();
  final country = TextEditingController();
  String entityType = 'Individual';
  bool business = false;
  bool professional = true;
  bool busy = false;

  @override
  void dispose() { name.dispose(); country.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity & Verification 2.0')),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: service.watchMine(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final status = (data?['status'] ?? 'not_started').toString();
          return ListView(padding: const EdgeInsets.all(16), children: [
            _hero(status),
            const SizedBox(height: 16),
            if (status != 'verified') _form(status),
            if (status == 'verified') _verifiedCard(),
            const SizedBox(height: 18),
            _safetyCard(),
            const SizedBox(height: 90),
          ]);
        },
      ),
    );
  }

  Widget _hero(String status) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF10271F), Color(0xFF101722)]), border: Border.all(color: const Color(0xFF10B981).withValues(alpha: .18))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.verified_user_outlined, color: Color(0xFF10B981), size: 28), SizedBox(width: 10), Text('Trust starts with identity', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900))]),
      const SizedBox(height: 8),
      const Text('Verify personal, professional or business identity so customers and partners can see stronger trust signals.', style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 12),
      Chip(label: Text(_statusLabel(status))),
    ]),
  );

  String _statusLabel(String s) => switch (s) { 'verified' => 'Verified', 'pending_backend_review' => 'Pending review', 'recheck_requested' => 'Recheck requested', _ => 'Not started' };

  Widget _form(String status) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Verification request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
    const SizedBox(height: 12),
    TextField(controller: name, decoration: const InputDecoration(labelText: 'Legal name')),
    const SizedBox(height: 10),
    TextField(controller: country, decoration: const InputDecoration(labelText: 'Country / region')),
    const SizedBox(height: 10),
    DropdownButtonFormField<String>(initialValue: entityType, items: const [DropdownMenuItem(value: 'Individual', child: Text('Individual')), DropdownMenuItem(value: 'Company', child: Text('Company')), DropdownMenuItem(value: 'Organization', child: Text('Organization'))], onChanged: (v) => setState(() => entityType = v ?? entityType), decoration: const InputDecoration(labelText: 'Identity type')),
    SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Business identity'), value: business, onChanged: (v) => setState(() => business = v)),
    SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Professional identity'), value: professional, onChanged: (v) => setState(() => professional = v)),
    const SizedBox(height: 8),
    FilledButton.icon(onPressed: busy ? null : _submit, icon: const Icon(Icons.shield_outlined), label: Text(status == 'not_started' ? 'Submit for verification' : 'Update request')),
    if (status == 'pending_backend_review' || status == 'recheck_requested') Padding(padding: const EdgeInsets.only(top: 10), child: TextButton.icon(onPressed: service.requestRecheck, icon: const Icon(Icons.refresh), label: const Text('Request another review'))),
  ])));

  Widget _verifiedCard() => const Card(child: Padding(padding: EdgeInsets.all(16), child: Row(children: [Icon(Icons.verified, color: Color(0xFF10B981), size: 30), SizedBox(width: 12), Expanded(child: Text('Your identity is marked verified. Backend controls the underlying verification evidence and badge eligibility.', style: TextStyle(fontWeight: FontWeight.w700)))])));

  Widget _safetyCard() => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
    Text('Privacy & safety', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
    SizedBox(height: 8),
    Text('SwipeBuy should collect only the identity evidence required for the selected verification path. Sensitive documents, checks and final badge decisions belong in protected backend workflows.', style: TextStyle(color: Colors.white70)),
  ])));

  Future<void> _submit() async {
    if (name.text.trim().isEmpty || country.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your legal name and country first.')));
      return;
    }
    setState(() => busy = true);
    try {
      await service.submit(legalName: name.text, country: country.text, entityType: entityType, business: business, professional: professional);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification request submitted for backend review.')));
    } finally { if (mounted) setState(() => busy = false); }
  }
}
