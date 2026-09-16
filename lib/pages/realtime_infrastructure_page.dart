import 'dart:async';
import 'package:flutter/material.dart';
import '../services/realtime_presence_service.dart';

class RealtimeInfrastructurePage extends StatefulWidget {
  const RealtimeInfrastructurePage({super.key});
  @override
  State<RealtimeInfrastructurePage> createState() => _RealtimeInfrastructurePageState();
}

class _RealtimeInfrastructurePageState extends State<RealtimeInfrastructurePage> {
  final service = RealtimePresenceService();
  Timer? _heartbeat;
  String status = 'offline';

  @override
  void initState() {
    super.initState();
    _set('online');
    _heartbeat = Timer.periodic(const Duration(seconds: 30), (_) => service.heartbeat());
  }

  Future<void> _set(String value) async {
    try {
      await service.setPresence(status: value);
      if (mounted) setState(() => status = value);
    } catch (_) {
      if (mounted) setState(() => status = 'signed out');
    }
  }

  @override
  void dispose() {
    _heartbeat?.cancel();
    service.goOffline();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Realtime Infrastructure 2.0')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Global Realtime Center', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('Live presence, typing signals, heartbeat and realtime delivery architecture.', style: TextStyle(color: Colors.white.withValues(alpha: .7))),
        const SizedBox(height: 18),
        Card(child: ListTile(leading: Icon(Icons.circle, color: status == 'online' ? Colors.green : Colors.orange), title: const Text('My presence'), subtitle: Text(status), trailing: PopupMenuButton<String>(onSelected: _set, itemBuilder: (_) => const [PopupMenuItem(value: 'online', child: Text('Online')), PopupMenuItem(value: 'away', child: Text('Away')), PopupMenuItem(value: 'offline', child: Text('Offline'))]))),
        const SizedBox(height: 12),
        _feature(Icons.flash_on_outlined, 'Realtime presence', 'Fast online/away/offline presence updates with heartbeat refresh.'),
        _feature(Icons.keyboard_alt_outlined, 'Typing indicators', 'Conversation typing signals for richer one-to-one and group messaging.'),
        _feature(Icons.sync_outlined, 'Event-driven architecture', 'Ready for WebSockets, pub/sub, push delivery and realtime fan-out.'),
        _feature(Icons.language_outlined, 'Global regions', 'Architecture supports regional realtime gateways and failover.'),
        _feature(Icons.monitor_heart_outlined, 'Health-aware delivery', 'Designed to connect with platform observability and resilience systems.'),
        _feature(Icons.security_outlined, 'Secure channels', 'Server-authorized presence, membership and realtime event publishing.'),
      ],
    ),
  );

  Widget _feature(IconData icon, String title, String subtitle) => Card(
    child: ListTile(leading: Icon(icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle)),
  );
}
