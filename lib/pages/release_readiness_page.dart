import 'package:flutter/material.dart';
import '../services/release_readiness_service.dart';

class ReleaseReadinessPage extends StatelessWidget {
  const ReleaseReadinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final checks = ReleaseReadinessService.checks;
    return Scaffold(
      appBar: AppBar(title: const Text('V15 Release Readiness')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Integration & Production Phase', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('This phase tracks what must be connected, verified and tested before the final V15 release.'),
          const SizedBox(height: 18),
          ...checks.map((check) => Card(
            child: ListTile(
              leading: Icon(_icon(check.status)),
              title: Text(check.area),
              subtitle: Text(check.description),
              trailing: Text(_label(check.status)),
            ),
          )),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Next priority: replace placeholders with verified production integrations, then run full device and end-to-end testing before V15.', style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(ReleaseStatus status) => switch (status) {
    ReleaseStatus.ready => Icons.check_circle_outline,
    ReleaseStatus.review => Icons.pending_actions_outlined,
    ReleaseStatus.blocked => Icons.block_outlined,
  };

  String _label(ReleaseStatus status) => switch (status) {
    ReleaseStatus.ready => 'Ready',
    ReleaseStatus.review => 'Review',
    ReleaseStatus.blocked => 'Blocked',
  };
}
