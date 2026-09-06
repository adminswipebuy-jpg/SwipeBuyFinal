import 'package:flutter/material.dart';
import '../services/privacy_center_service.dart';

class PrivacyCenterPage extends StatefulWidget {
  const PrivacyCenterPage({super.key});
  @override
  State<PrivacyCenterPage> createState() => _PrivacyCenterPageState();
}

class _PrivacyCenterPageState extends State<PrivacyCenterPage> {
  final _service = PrivacyCenterService();
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String message) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDeletion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request account deletion?'),
        content: const Text('This sends a deletion request to the trusted backend. The client does not delete account data directly.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continue')),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(_service.requestAccountDeletion, 'Account deletion request submitted for review.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Center 2.0')),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _service.watchProfile(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? const <String, dynamic>{};
          final personalizedAds = data['personalizedAds'] != false;
          final analytics = data['analyticsSharing'] != false;
          final aiContext = data['aiPersonalization'] != false;
          return ListView(padding: const EdgeInsets.all(16), children: [
            Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Your data, your controls', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Manage optional personalization and request access to privacy actions. Sensitive account changes stay backend-controlled.'),
              const SizedBox(height: 12),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Personalized recommendations'), subtitle: const Text('Allow optional signals to improve your SwipeBuy recommendations.'), value: aiContext, onChanged: _busy ? null : (v) => _run(() => _service.updateControl('aiPersonalization', v), 'Recommendation preference updated.')),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Personalized ads'), subtitle: const Text('Allow optional ad personalization where legally available.'), value: personalizedAds, onChanged: _busy ? null : (v) => _run(() => _service.updateControl('personalizedAds', v), 'Ad personalization preference updated.')),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Analytics sharing'), subtitle: const Text('Control optional product analytics signals.'), value: analytics, onChanged: _busy ? null : (v) => _run(() => _service.updateControl('analyticsSharing', v), 'Analytics preference updated.')),
            ]))),
            const SizedBox(height: 12),
            Card(child: ListTile(leading: const Icon(Icons.download_outlined), title: const Text('Request my data'), subtitle: const Text('Start a backend-managed data export request.'), onTap: _busy ? null : () => _run(_service.requestDataExport, 'Data export request submitted.'))),
            const SizedBox(height: 8),
            Card(child: ListTile(leading: const Icon(Icons.support_agent_outlined), title: const Text('Privacy review'), subtitle: const Text('Request human review of a privacy concern.'), onTap: _busy ? null : () => _run(() => _service.requestPrivacyReview('User requested a privacy review.'), 'Privacy review submitted.'))),
            const SizedBox(height: 8),
            Card(child: ListTile(leading: const Icon(Icons.delete_forever_outlined), title: const Text('Request account deletion'), subtitle: const Text('Starts a protected backend review before deletion.'), onTap: _busy ? null : _confirmDeletion)),
            const SizedBox(height: 20),
            const Text('Transparency', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Privacy controls are preferences, not proof of compliance. Your production backend should enforce data retention, access, export, deletion, consent, regional requirements and audit logging.'),
          ]);
        },
      ),
    );
  }
}
