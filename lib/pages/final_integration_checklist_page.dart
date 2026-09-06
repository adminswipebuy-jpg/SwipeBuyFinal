import 'package:flutter/material.dart';

class FinalIntegrationChecklistPage extends StatelessWidget {
  const FinalIntegrationChecklistPage({super.key});

  static const _items = <_Check>[
    _Check('Source', 'Remove duplicate/unreachable navigation paths and keep imports clean.', Icons.code_rounded, 'Source check'),
    _Check('Firebase', 'Verify production Auth, Firestore, Storage and Functions configuration.', Icons.cloud_done_outlined, 'Backend check'),
    _Check('Payments', 'Verify provider callbacks, ledger reconciliation, refunds and disputes.', Icons.payments_outlined, 'Payment check'),
    _Check('Providers', 'Verify Maps, media/video and LIVE provider credentials and quotas.', Icons.hub_outlined, 'Provider check'),
    _Check('Security', 'Deploy rules and test authorization boundaries with real accounts.', Icons.security_outlined, 'Security check'),
    _Check('Device QA', 'Run the primary journeys end-to-end on supported Android devices.', Icons.phone_android_rounded, 'Device check'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Final Integration Checklist')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(colors: [Color(0xFF14231F), Color(0xFF101720)]),
              border: Border.all(color: const Color(0x2238D9A9)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Final integration only', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text('No new product features here. Complete these checks, then use the V15 Release Gate for the final release decision.'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._items.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(child: Icon(item.icon, size: 20)),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(item.description),
                  trailing: Text(item.status, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              )),
          const SizedBox(height: 6),
          Text('Important: these are release checks, not proof that the production environment has already passed them. Flutter release builds and provider verification still require the real toolchain/environment.', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Check {
  final String title;
  final String description;
  final IconData icon;
  final String status;
  const _Check(this.title, this.description, this.icon, this.status);
}
