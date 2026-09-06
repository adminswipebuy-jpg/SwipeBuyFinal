import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/community_events_service.dart';

class CommunityEventsPage extends StatefulWidget {
  const CommunityEventsPage({super.key});
  @override State<CommunityEventsPage> createState() => _CommunityEventsPageState();
}

class _CommunityEventsPageState extends State<CommunityEventsPage> with SingleTickerProviderStateMixin {
  late final TabController tabs = TabController(length: 3, vsync: this);
  final service = CommunityEventsService();

  @override void dispose() { tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Community Events & LIVE', style: TextStyle(fontWeight: FontWeight.w900)),
      bottom: TabBar(controller: tabs, tabs: const [Tab(text: 'Events'), Tab(text: 'LIVE Groups'), Tab(text: 'Fan Experience')]),
    ),
    body: TabBarView(controller: tabs, children: [_events(), _liveGroups(), _fanExperience()]),
  );

  Widget _events() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: service.upcomingEvents(),
    builder: (_, snap) {
      if (snap.hasError) return const Center(child: Text('Unable to load events right now.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return const _Empty(icon: Icons.event_outlined, title: 'No upcoming events', subtitle: 'Follow communities and creators to see live events here.');
      return ListView.separated(
        padding: const EdgeInsets.all(16), itemCount: docs.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final d = docs[i].data(); final id = docs[i].id;
          return Card(color: const Color(0xFF111720), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.event, color: Colors.white70), const SizedBox(width: 10), Expanded(child: Text(d['title']?.toString() ?? 'Community event', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))), _EventFollow(service: service, eventId: id)]),
            const SizedBox(height: 6), Text('${d['category'] ?? 'Community'} • ${d['format'] ?? 'Online'}', style: const TextStyle(color: Colors.white60)),
            if ((d['description']?.toString() ?? '').isNotEmpty) ...[const SizedBox(height: 6), Text(d['description'].toString(), maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54))],
            const SizedBox(height: 10), Row(children: [const Icon(Icons.schedule, size: 16, color: Colors.white54), const SizedBox(width: 6), Text(d['startLabel']?.toString() ?? 'Start time set by host', style: const TextStyle(color: Colors.white54)), const Spacer(), TextButton(onPressed: () => _remind(id), child: const Text('Remind me'))])
          ])));
        },
      );
    },
  );

  Widget _liveGroups() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: service.liveGroups(),
    builder: (_, snap) {
      if (snap.hasError) return const Center(child: Text('Unable to load LIVE groups right now.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return const _Empty(icon: Icons.live_tv_outlined, title: 'No LIVE groups now', subtitle: 'When creators go LIVE with communities, their groups appear here.');
      return ListView.builder(padding: const EdgeInsets.all(16), itemCount: docs.length, itemBuilder: (_, i) {
        final d = docs[i].data(); final id = docs[i].id;
        return Card(color: const Color(0xFF111720), child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.live_tv)),
          title: Text(d['title']?.toString() ?? 'LIVE community group', style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text('${d['category'] ?? 'Community'} • ${d['viewerCount'] ?? 0} watching\n${d['creatorName'] ?? 'Creator'}'),
          trailing: FilledButton(onPressed: () async { await service.joinLiveGroup(id); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined LIVE group.'))); }, child: const Text('Join')),
        ));
      });
    },
  );

  Widget _fanExperience() => ListView(padding: const EdgeInsets.all(18), children: [
    const Text('Go beyond the feed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
    const SizedBox(height: 8),
    const Text('Request fan experiences from creators. Approval, pricing, payments and access are handled by trusted backend services.', style: TextStyle(color: Colors.white54)),
    const SizedBox(height: 18),
    _ExperienceCard(icon: Icons.video_call_outlined, title: 'Private video session', subtitle: 'Request a scheduled creator video session.', type: 'private_video'),
    _ExperienceCard(icon: Icons.groups_2_outlined, title: 'Small group session', subtitle: 'Ask to join an intimate creator group experience.', type: 'small_group'),
    _ExperienceCard(icon: Icons.star_outline, title: 'Personal shout-out', subtitle: 'Request a personalized message or shout-out.', type: 'shout_out'),
  ]);

  Future<void> _remind(String eventId) async {
    await service.requestEventReminder(eventId, cadence: 'event');
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder request saved.')));
  }
}

class _ExperienceCard extends StatelessWidget {
  final IconData icon; final String title, subtitle, type;
  const _ExperienceCard({required this.icon, required this.title, required this.subtitle, required this.type});
  @override Widget build(BuildContext context) => Card(color: const Color(0xFF111720), child: ListTile(
    leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right),
    onTap: () async { final creator = TextEditingController(); final note = TextEditingController(); await showDialog(context: context, builder: (_) => AlertDialog(title: Text(title), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: creator, decoration: const InputDecoration(labelText: 'Creator ID')), TextField(controller: note, decoration: const InputDecoration(labelText: 'Note'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async { final id = creator.text.trim(); await CommunityEventsService().requestFanExperience(creatorId: id, experienceType: type, note: note.text); if (context.mounted) Navigator.pop(context); }, child: const Text('Request'))])); creator.dispose(); note.dispose(); },
  ));
}

class _EventFollow extends StatelessWidget { final CommunityEventsService service; final String eventId; const _EventFollow({required this.service, required this.eventId}); @override Widget build(BuildContext context) => StreamBuilder<bool>(stream: service.isFollowingEvent(eventId), builder: (_, snap) { final following = snap.data ?? false; return OutlinedButton(onPressed: () => following ? service.unfollowEvent(eventId) : service.followEvent(eventId), child: Text(following ? 'Following' : 'Follow')); }); }
class _Empty extends StatelessWidget { final IconData icon; final String title, subtitle; const _Empty({required this.icon, required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 58, color: Colors.white30), const SizedBox(height: 14), Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54))]))); }
