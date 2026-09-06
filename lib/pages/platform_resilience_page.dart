import 'package:flutter/material.dart';
import '../services/platform_resilience_service.dart';

class PlatformResiliencePage extends StatefulWidget {
  const PlatformResiliencePage({super.key});
  @override State<PlatformResiliencePage> createState() => _PlatformResiliencePageState();
}

class _PlatformResiliencePageState extends State<PlatformResiliencePage> {
  final service = PlatformResilienceService();
  bool loading = false;

  Future<void> _request(String type) async {
    setState(() => loading = true);
    try {
      await service.createRecoveryRequest(type);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$type request created')),
      );
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request could not be created')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Platform Resilience')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.cloud_done_outlined, size: 36),
              const SizedBox(height: 10),
              const Text('SwipeBuy Resilience Center', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Monitor recovery readiness, service health and continuity controls.'),
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: const [
                Chip(label: Text('Backups')), Chip(label: Text('Recovery')), Chip(label: Text('Service health')), Chip(label: Text('Incident response')),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        ...[
          ('Backup & Restore', Icons.backup_outlined, 'Request a verified backup/recovery review.'),
          ('Service Health Review', Icons.monitor_heart_outlined, 'Request an operational health assessment.'),
          ('Disaster Recovery Drill', Icons.sync_lock_outlined, 'Create a controlled resilience-drill request.'),
          ('Continuity Incident', Icons.warning_amber_outlined, 'Open a high-level continuity incident for review.'),
        ].map((item) => Card(
          child: ListTile(
            leading: Icon(item.$2),
            title: Text(item.$1),
            subtitle: Text(item.$3),
            trailing: loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.chevron_right),
            onTap: loading ? null : () => _request(item.$1),
          ),
        )),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.admin_panel_settings_outlined),
            title: Text('Production architecture note'),
            subtitle: Text('Backup, failover, restore, incident recovery and service-health decisions must be enforced by trusted backend infrastructure.'),
          ),
        ),
      ],
    ),
  );
}
