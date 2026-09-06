import 'package:flutter/material.dart';
import '../services/data_governance_service.dart';

class DataGovernancePage extends StatefulWidget {
  const DataGovernancePage({super.key});
  @override
  State<DataGovernancePage> createState() => _DataGovernancePageState();
}

class _DataGovernancePageState extends State<DataGovernancePage> {
  final _service = DataGovernanceService();
  String _region = 'Global / Not specified';
  bool _personalization = true;
  bool _analytics = true;
  bool _marketing = false;
  bool _sharing = false;
  bool _busy = false;

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await _service.saveConsent(_region, {
        'personalization': _personalization,
        'analytics': _analytics,
        'marketing': _marketing,
        'thirdPartySharing': _sharing,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consent preferences saved')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to save: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _review(String topic) async {
    try {
      await _service.requestComplianceReview(region: _region, topic: topic);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compliance review requested')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to request review: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Governance & Consent 2.0')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Regional Privacy Controls', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Set your region so SwipeBuy can apply the appropriate consent and data-governance workflow.'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _region,
            items: const [
              DropdownMenuItem(value: 'Global / Not specified', child: Text('Global / Not specified')),
              DropdownMenuItem(value: 'European Economic Area', child: Text('European Economic Area')),
              DropdownMenuItem(value: 'United Kingdom', child: Text('United Kingdom')),
              DropdownMenuItem(value: 'Ghana / West Africa', child: Text('Ghana / West Africa')),
              DropdownMenuItem(value: 'North America', child: Text('North America')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _region = v ?? _region),
          ),
          const SizedBox(height: 20),
          const Text('Consent Controls', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SwitchListTile(value: _personalization, onChanged: (v) => setState(() => _personalization = v), title: const Text('Personalized experience'), subtitle: const Text('Use activity to tailor discovery and recommendations.')),
          SwitchListTile(value: _analytics, onChanged: (v) => setState(() => _analytics = v), title: const Text('Analytics'), subtitle: const Text('Allow product analytics and performance measurement.')),
          SwitchListTile(value: _marketing, onChanged: (v) => setState(() => _marketing = v), title: const Text('Marketing communications'), subtitle: const Text('Allow promotional messages where permitted.')),
          SwitchListTile(value: _sharing, onChanged: (v) => setState(() => _sharing = v), title: const Text('Optional third-party sharing'), subtitle: const Text('Only enable where lawful and separately consented.')),
          FilledButton.icon(onPressed: _busy ? null : _save, icon: const Icon(Icons.save_outlined), label: Text(_busy ? 'Saving…' : 'Save Consent Preferences')),
          const SizedBox(height: 24),
          const Text('Transparency & Compliance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Request a privacy review for your region, consent record, or data-processing question.'),
          ListTile(leading: const Icon(Icons.gavel_outlined), title: const Text('Request regional privacy review'), onTap: () => _review('regional privacy review')),
          ListTile(leading: const Icon(Icons.fact_check_outlined), title: const Text('Request consent-record review'), onTap: () => _review('consent record review')),
          ListTile(leading: const Icon(Icons.storage_outlined), title: const Text('Request data-processing explanation'), onTap: () => _review('data processing explanation')),
          const SizedBox(height: 12),
          const Text('Sensitive legal/compliance decisions are handled by the backend and appropriate human or specialist workflows; these client controls do not by themselves establish legal compliance.', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
