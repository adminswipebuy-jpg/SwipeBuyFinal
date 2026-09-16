import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/smart_alert_service.dart';
import 'notification_preferences_page.dart';

class SmartAlertsPage extends StatelessWidget {
  final SmartAlertService service;
  SmartAlertsPage({super.key, SmartAlertService? service}) : service = service ?? SmartAlertService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Alerts'),
        actions: [
          IconButton(
            tooltip: 'Notification settings',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPreferencesPage())),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.alerts(),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Unable to load smart alerts.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          final unread = docs.where((d) => d.data()['read'] != true).length;
          return Column(
            children: [
              if (unread > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Text('$unread new alerts', style: const TextStyle(fontWeight: FontWeight.w900)),
                      const Spacer(),
                      TextButton(onPressed: service.markAllRead, child: const Text('Mark all read')),
                    ],
                  ),
                ),
              Expanded(
                child: docs.isEmpty
                    ? const Center(child: Text('Your personalized alerts will appear here.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final doc = docs[i];
                          final data = doc.data();
                          final read = data['read'] == true;
                          return Card(
                            color: read ? const Color(0xFF111720) : const Color(0xFF17221C),
                            child: ListTile(
                              leading: CircleAvatar(child: Icon(_icon(data['type']?.toString()))),
                              title: Text(data['title']?.toString() ?? 'SwipeBuy Alert', style: TextStyle(fontWeight: read ? FontWeight.w600 : FontWeight.w900)),
                              subtitle: Text(data['body']?.toString() ?? ''),
                              trailing: read ? null : const Icon(Icons.circle, size: 10),
                              onTap: () => service.markRead(doc.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _icon(String? type) {
    switch (type) {
      case 'price': return Icons.trending_up;
      case 'job': return Icons.work_outline;
      case 'property': return Icons.home_work_outlined;
      case 'live': return Icons.wifi_tethering;
      case 'news': return Icons.newspaper_outlined;
      case 'sports': return Icons.sports_soccer;
      default: return Icons.auto_awesome;
    }
  }
}
