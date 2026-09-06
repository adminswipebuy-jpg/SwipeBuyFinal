import 'package:flutter/material.dart';

class V15ReleaseGatePage extends StatelessWidget {
  const V15ReleaseGatePage({super.key});

  static const _gates = <_Gate>[
    _Gate('Flutter build', 'Run flutter pub get, analyze, test and a release APK/AAB build.', 'Local/CI verification'),
    _Gate('Firebase', 'Verify Auth, Firestore, Storage and Functions against the production project.', 'Backend verification'),
    _Gate('Payments', 'Verify checkout, wallet/ledger, refunds, disputes and webhook reconciliation.', 'Payment verification'),
    _Gate('Maps & location', 'Add the production Google Maps key and verify location/nearby flows on devices.', 'Provider verification'),
    _Gate('Video & LIVE', 'Verify upload, transcoding, playback and LIVE provider delivery with real media.', 'Provider verification'),
    _Gate('Ads & monetization', 'Replace test ad IDs and verify policy-safe production placements.', 'Monetization verification'),
    _Gate('Security rules', 'Deploy and validate Firebase rules; test unauthorized reads/writes and role boundaries.', 'Security verification'),
    _Gate('Real-device E2E', 'Test sign-in → browse → purchase/book/apply → chat/notification on supported Android devices.', 'Device verification'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('V15 Release Gate')),
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
                Text('V15 is a release gate, not another feature sprint', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text('Every gate below must be verified in the real environment before calling the app production-ready.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._gates.map((gate) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.radio_button_unchecked_outlined),
                  title: Text(gate.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${gate.description}\n${gate.owner}'),
                  isThreeLine: true,
                ),
              )),
          const SizedBox(height: 6),
          Text('Current limitation: Flutter SDK is not available in this working environment, so source-level checks cannot replace a real release build.', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Gate {
  final String title;
  final String description;
  final String owner;
  const _Gate(this.title, this.description, this.owner);
}
