import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import 'notification_preferences_page.dart';

class NotificationsPage extends StatelessWidget {
  final NotificationService service;
  const NotificationsPage({super.key, NotificationService? service}) : service = service ?? NotificationService();

  Future<void> markAllRead(BuildContext context) async {
    final snap = await service.notifications().first;
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      if (doc.data()['read'] != true) batch.update(doc.reference, {'read': true, 'readAt': FieldValue.serverTimestamp()});
    }
    await batch.commit();
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All notifications marked as read')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [IconButton(onPressed: () => markAllRead(context), icon: const Icon(Icons.done_all), tooltip: 'Mark all read'), IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPreferencesPage())), icon: const Icon(Icons.settings_outlined), tooltip: 'Notification settings')],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.notifications(),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Unable to load notifications.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No notifications yet.'));
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data();
              final read = data['read'] == true;
              return ListTile(
                tileColor: read ? null : Colors.white.withOpacity(.035),
                leading: CircleAvatar(child: Icon(read ? Icons.notifications_none : Icons.notifications_active)),
                title: Text(data['title']?.toString() ?? 'SwipeBuy', style: TextStyle(fontWeight: read ? FontWeight.w600 : FontWeight.w900)),
                subtitle: Text(data['body']?.toString() ?? ''),
                trailing: read ? null : const SizedBox(width: 8, height: 8, child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle))),
                onTap: () => service.markRead(doc.id),
              );
            },
          );
        },
      ),
    );
  }
}
