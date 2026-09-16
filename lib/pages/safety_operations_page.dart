import 'package:flutter/material.dart';
import '../services/safety_operations_service.dart';

class SafetyOperationsPage extends StatefulWidget {
  const SafetyOperationsPage({super.key});

  @override
  State<SafetyOperationsPage> createState() => _SafetyOperationsPageState();
}

class _SafetyOperationsPageState extends State<SafetyOperationsPage> {
  final _service = SafetyOperationsService();
  final _description = TextEditingController();
  String _category = 'Harassment';
  String _severity = 'standard';
  bool _submitting = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_description.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await _service.submitIncident(
        category: _category,
        severity: _severity,
        description: _description.text,
      );
      if (mounted) {
        _description.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Safety report submitted for review.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Operations')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Report an incident', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Use this space to report urgent platform-safety concerns. High-impact enforcement is handled by authorized backend teams.'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: const ['Harassment', 'Scam/Fraud', 'Threat', 'Child Safety', 'Account Compromise', 'Other']
                .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _severity,
            items: const ['standard', 'high', 'urgent']
                .map((v) => DropdownMenuItem(value: v, child: Text(v.toUpperCase()))).toList(),
            onChanged: (v) => setState(() => _severity = v ?? _severity),
            decoration: const InputDecoration(labelText: 'Severity', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'What happened?',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: const Icon(Icons.flag_outlined),
            label: Text(_submitting ? 'Submitting...' : 'Submit report'),
          ),
          const SizedBox(height: 28),
          const Text('Your reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StreamBuilder(
            stream: _service.myIncidents(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No safety reports yet.');
              }
              return Column(
                children: snapshot.data!.docs.take(10).map<Widget>((doc) {
                  final data = doc.data();
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.shield_outlined),
                      title: Text('${data['category'] ?? 'Report'} • ${data['severity'] ?? 'standard'}'),
                      subtitle: Text('${data['status'] ?? 'submitted'}'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
