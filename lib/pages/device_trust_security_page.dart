import 'package:flutter/material.dart';
import '../services/device_trust_service.dart';

class DeviceTrustSecurityPage extends StatefulWidget {
  const DeviceTrustSecurityPage({super.key});
  @override
  State<DeviceTrustSecurityPage> createState() => _DeviceTrustSecurityPageState();
}

class _DeviceTrustSecurityPageState extends State<DeviceTrustSecurityPage> {
  final service = DeviceTrustService();
  final deviceLabel = TextEditingController();
  final recoveryReason = TextEditingController();

  @override
  void dispose() {
    deviceLabel.dispose();
    recoveryReason.dispose();
    super.dispose();
  }

  Future<void> _trustDevice() async {
    try {
      await service.requestDeviceTrust(deviceLabel: deviceLabel.text);
      if (mounted) {
        deviceLabel.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Device trust request submitted for backend review.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _recovery() async {
    try {
      await service.requestAccountRecoveryReview(reason: recoveryReason.text);
      if (mounted) {
        recoveryReason.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account recovery review submitted.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Trust & Account Security 2.0')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Protect your account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            SizedBox(height: 8),
            Text('Trusted devices, recovery reviews and session controls are verified by SwipeBuy backend security systems.'),
          ]))),
          const SizedBox(height: 12),
          StreamBuilder<List<Map<String, dynamic>>>(stream: service.watchDevices(), builder: (context, snap) {
            final devices = snap.data ?? const [];
            return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Trusted devices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              if (devices.isEmpty) const Text('No backend-confirmed trusted devices yet.'),
              ...devices.map((d) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.devices_other_outlined), title: Text('${d['deviceLabel'] ?? 'Device'}'), subtitle: Text('${d['status'] ?? 'unknown'}'))),
              const SizedBox(height: 6),
              TextField(controller: deviceLabel, decoration: const InputDecoration(labelText: 'Device name', hintText: 'My Samsung phone')),
              const SizedBox(height: 8),
              FilledButton.icon(onPressed: _trustDevice, icon: const Icon(Icons.verified_user_outlined), label: const Text('Request device trust')),
            ])));
          }),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Session protection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Request the backend to sign out every other active session if you suspect account access.'),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: () async {
              try {
                await service.requestSignOutAllOtherDevices();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session security request submitted.')));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
              }
            }, icon: const Icon(Icons.logout_outlined), label: const Text('Secure other sessions')),
          ]))),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Account recovery review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            TextField(controller: recoveryReason, maxLines: 3, decoration: const InputDecoration(labelText: 'Why do you need a recovery review?')),
            const SizedBox(height: 8),
            FilledButton.icon(onPressed: _recovery, icon: const Icon(Icons.lock_reset_outlined), label: const Text('Request recovery review')),
          ]))),
          const SizedBox(height: 16),
          const Text('Security note: device trust and session enforcement must be decided by the backend. Never rely on a client-side flag as proof of identity or account ownership.', style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
