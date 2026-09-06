import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/moderation_service.dart';
import 'notification_preferences_page.dart';

class SafetyCenterPage extends StatefulWidget {
  const SafetyCenterPage({super.key});
  @override
  State<SafetyCenterPage> createState() => _SafetyCenterPageState();
}

class _SafetyCenterPageState extends State<SafetyCenterPage> {
  final service = ModerationService();
  bool sensitiveFilter = true;
  bool messageRequests = true;
  bool personalizedNotifications = true;
  bool saving = false;

  Future<void> _save() async {
    setState(() => saving = true);
    try {
      await service.saveSafetySettings(
        sensitiveContentFilter: sensitiveFilter,
        messageRequests: messageRequests,
        personalizedNotifications: personalizedNotifications,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Safety settings saved.')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _confirmUnblock(String uid) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Unblock user?'),
      content: Text('Remove $uid from your blocked list?'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Unblock'))],
    ));
    if (ok == true) await service.unblockUser(uid);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Safety & privacy')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Your safety matters', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('Control what you see, who can contact you, and how SwipeBuy uses alerts to keep the experience useful.', style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 18),
            Card(color: const Color(0xFF111720), child: Column(children: [
              SwitchListTile(title: const Text('Sensitive content filter'), subtitle: const Text('Reduce potentially sensitive content in discovery.'), value: sensitiveFilter, onChanged: (v) => setState(() => sensitiveFilter = v)),
              SwitchListTile(title: const Text('Allow message requests'), subtitle: const Text('Let people you do not follow start a request.'), value: messageRequests, onChanged: (v) => setState(() => messageRequests = v)),
              SwitchListTile(title: const Text('Personalized notifications'), subtitle: const Text('Use your interests to prioritize relevant alerts.'), value: personalizedNotifications, onChanged: (v) => setState(() => personalizedNotifications = v)),
            ])),
            const SizedBox(height: 12),
            SizedBox(height: 50, child: FilledButton(onPressed: saving ? null : _save, child: saving ? const CircularProgressIndicator() : const Text('Save safety settings'))),
            const SizedBox(height: 14),
            Card(color: const Color(0xFF111720), child: Column(children: [
              ListTile(leading: const Icon(Icons.notifications_active_outlined), title: const Text('Notification controls'), subtitle: const Text('Fine-tune social, jobs, market and LIVE alerts.'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPreferencesPage()))),
              const Divider(height: 1),
              const ListTile(leading: Icon(Icons.flag_outlined), title: Text('Report harmful content'), subtitle: Text('Use Report from content and message menus so our moderation team can review it.')),
              const ListTile(leading: Icon(Icons.security_outlined), title: Text('Security tips'), subtitle: Text('Never share passwords, one-time codes or payment credentials in chat.')),
            ])),
            const SizedBox(height: 14),
            const Text('Blocked accounts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: service.blockedUsers(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                final docs = snap.data?.docs ?? const [];
                if (docs.isEmpty) return const Card(color: Color(0xFF111720), child: ListTile(title: Text('No blocked accounts'), subtitle: Text('Blocked accounts will appear here.')));
                return Card(color: const Color(0xFF111720), child: Column(children: docs.map((d) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_off_outlined)),
                  title: Text(d.id),
                  trailing: TextButton(onPressed: () => _confirmUnblock(d.id), child: const Text('Unblock')),
                )).toList()));
              },
            ),
          ],
        ),
      );
}
