import 'package:flutter/material.dart';
import '../services/mfa_security_service.dart';

class MfaPasskeySecurityPage extends StatefulWidget {
  const MfaPasskeySecurityPage({super.key});
  @override
  State<MfaPasskeySecurityPage> createState() => _MfaPasskeySecurityPageState();
}

class _MfaPasskeySecurityPageState extends State<MfaPasskeySecurityPage> {
  final _service = MfaSecurityService();
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String success) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passkeys & MFA 2.0')),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _service.watchSecurityProfile(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? const <String, dynamic>{};
          final mfaEnabled = data['mfaEnabled'] == true;
          final passkeys = (data['passkeyCount'] ?? 0).toString();
          return ListView(padding: const EdgeInsets.all(16), children: [
            Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('High-security login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(mfaEnabled ? 'Multi-factor authentication is enabled.' : 'Add an extra login factor for stronger account protection.'),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _busy ? null : () => _run(() => _service.requestMfaSetup(method: 'authenticator_app'), 'MFA setup request sent.'),
                icon: const Icon(Icons.security), label: const Text('Set up authenticator MFA'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _run(_service.requestPasskeyEnrollment, 'Passkey enrollment request sent.'),
                icon: const Icon(Icons.fingerprint), label: Text('Add passkey ($passkeys active)'),
              ),
            ]))),
            const SizedBox(height: 12),
            Card(child: ListTile(
              leading: const Icon(Icons.phonelink_lock_outlined),
              title: const Text('Recovery protection'),
              subtitle: const Text('Passkeys and MFA changes should be verified by the secure backend before taking effect.'),
            )),
            const SizedBox(height: 12),
            Card(child: ListTile(
              leading: const Icon(Icons.lock_reset_outlined),
              title: const Text('Disable MFA'),
              subtitle: const Text('Creates a security review request instead of disabling protection immediately.'),
              onTap: _busy ? null : () => _run(_service.requestMfaDisable, 'MFA disable request sent for security review.'),
            )),
            const SizedBox(height: 20),
            const Text('Security note', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('No secrets, one-time codes or passkey credentials are stored by this client workflow. Production authentication enforcement belongs in your trusted identity/backend layer.'),
          ]);
        },
      ),
    );
  }
}
