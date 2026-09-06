import 'package:flutter/material.dart';

class V15ReleaseCandidatePage extends StatelessWidget {
  const V15ReleaseCandidatePage({super.key});

  static const _checks = <_CandidateCheck>[
    _CandidateCheck('Source handoff', 'Freeze product code changes except release blockers.', Icons.lock_outline, 'Ready to freeze'),
    _CandidateCheck('Configuration', 'Set production Firebase, Maps, media, payment and ads configuration.', Icons.settings_outlined, 'Environment required'),
    _CandidateCheck('Backend validation', 'Deploy and test trusted backend flows, rules, webhooks and ledger reconciliation.', Icons.cloud_done_outlined, 'Environment required'),
    _CandidateCheck('Provider validation', 'Verify external media, LIVE, Maps and payment providers with production-safe credentials.', Icons.hub_outlined, 'Provider required'),
    _CandidateCheck('Device validation', 'Run sign-in, browse, checkout/booking, chat, notifications and media flows on real devices.', Icons.phone_android_outlined, 'Device required'),
    _CandidateCheck('Release build', 'Run flutter pub get, analyze, test, then produce and install the release APK/AAB.', Icons.build_circle_outlined, 'Toolchain required'),
    _CandidateCheck('Go / no-go', 'Only ship after all release gates are green and rollback/monitoring are confirmed.', Icons.verified_outlined, 'Final sign-off'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('V15 Release Candidate')),
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
                Text('V15 Release Candidate', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text('This is the final handoff checkpoint. No new product features are planned here; the remaining work is environment validation and release QA.'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._checks.map((check) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(child: Icon(check.icon, size: 20)),
                  title: Text(check.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(check.description),
                  ),
                  trailing: Text(check.status, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                ),
              )),
          const SizedBox(height: 6),
          Text(
            'Important: this screen records what must be verified; it does not claim that production infrastructure has already passed. The current working environment does not have the Flutter SDK, so a real APK/AAB build must be completed elsewhere or in CI.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _CandidateCheck {
  final String title;
  final String description;
  final IconData icon;
  final String status;
  const _CandidateCheck(this.title, this.description, this.icon, this.status);
}
