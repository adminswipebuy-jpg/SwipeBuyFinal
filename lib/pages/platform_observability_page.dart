import 'package:flutter/material.dart';
import '../services/platform_observability_service.dart';

class PlatformObservabilityPage extends StatefulWidget {
  const PlatformObservabilityPage({super.key});
  @override State<PlatformObservabilityPage> createState() => _PlatformObservabilityPageState();
}

class _PlatformObservabilityPageState extends State<PlatformObservabilityPage> {
  final service = PlatformObservabilityService();
  final details = TextEditingController();
  bool loading = false;

  Future<void> _request(String type) async {
    setState(() => loading = true);
    try {
      await service.createReviewRequest(type: type, details: details.text.isEmpty ? 'User requested $type review.' : details.text);
      details.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$type request created')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request could not be created')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Platform Observability')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.monitor_heart_outlined, size: 38),
          const SizedBox(height: 10),
          const Text('SwipeBuy Observability Center', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Track performance, reliability, latency and user-facing service health signals.'),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: const [
            Chip(label: Text('Performance')), Chip(label: Text('Reliability')), Chip(label: Text('Latency')), Chip(label: Text('Errors')),
          ]),
        ]))),
        const SizedBox(height: 12),
        TextField(controller: details, maxLines: 4, decoration: const InputDecoration(labelText: 'Issue details (optional)', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        ...[
          ('Performance Review', Icons.speed_outlined),
          ('Reliability Review', Icons.health_and_safety_outlined),
          ('Incident Diagnostics', Icons.bug_report_outlined),
          ('Regional Service Review', Icons.public_outlined),
        ].map((item) => Card(child: ListTile(
          leading: Icon(item.$2), title: Text(item.$1), subtitle: const Text('Create a backend review request.'),
          trailing: loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.chevron_right),
          onTap: loading ? null : () => _request(item.$1),
        ))),
        const SizedBox(height: 12),
        const Card(child: ListTile(
          leading: Icon(Icons.admin_panel_settings_outlined), title: Text('Production architecture note'),
          subtitle: Text('Telemetry collection, alerting, tracing, SLOs and automated remediation must run in trusted backend infrastructure.'),
        )),
      ],
    ),
  );
}
