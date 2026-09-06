import 'package:flutter/material.dart';
import '../services/notification_intelligence_service.dart';

class NotificationIntelligencePage extends StatefulWidget {
  const NotificationIntelligencePage({super.key});
  @override
  State<NotificationIntelligencePage> createState() => _NotificationIntelligencePageState();
}

class _NotificationIntelligencePageState extends State<NotificationIntelligencePage> {
  final service = NotificationIntelligenceService();
  bool push = true, realtime = true, personalized = true, digest = true;

  Future<void> save(String channel, bool value, void Function() local) async {
    local();
    await service.recordPreference(channel, value);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notification Intelligence 2.0')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Smarter alerts, calmer delivery', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Control how SwipeBuy prioritizes realtime events, alerts and digests.', style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 18),
        SwitchListTile(title: const Text('Push notifications'), value: push, onChanged: (v) => save('pushEnabled', v, () => setState(() => push = v))),
        SwitchListTile(title: const Text('Realtime activity'), value: realtime, onChanged: (v) => save('realtimeEnabled', v, () => setState(() => realtime = v))),
        SwitchListTile(title: const Text('Personalized priority'), value: personalized, onChanged: (v) => save('personalized', v, () => setState(() => personalized = v))),
        SwitchListTile(title: const Text('Daily digest'), value: digest, onChanged: (v) => save('dailyDigest', v, () => setState(() => digest = v))),
        const SizedBox(height: 10),
        Card(child: ListTile(leading: const Icon(Icons.shield_outlined), title: const Text('Delivery review'), subtitle: const Text('Request a backend review for missing, delayed or excessive notifications.'), onTap: () async {
          await service.requestDeliveryReview();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery review requested')));
        })),
      ],
    ),
  );
}
