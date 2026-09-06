import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/global_community_service.dart';
import 'community_detail_page.dart';

class GlobalCreatorCommunityPage extends StatefulWidget {
  const GlobalCreatorCommunityPage({super.key});
  @override State<GlobalCreatorCommunityPage> createState() => _GlobalCreatorCommunityPageState();
}

class _GlobalCreatorCommunityPageState extends State<GlobalCreatorCommunityPage> with SingleTickerProviderStateMixin {
  late final TabController tabs = TabController(length: 2, vsync: this);
  final service = GlobalCommunityService();

  @override
  void dispose() { tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Global Creator & Community', style: TextStyle(fontWeight: FontWeight.w900)),
      bottom: TabBar(controller: tabs, tabs: const [Tab(text: 'Communities'), Tab(text: 'Creator Hubs')]),
    ),
    body: TabBarView(controller: tabs, children: [_communities(), _creatorHubs()]),
  );

  Widget _communities() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: service.featuredCommunities(),
    builder: (context, snap) {
      if (snap.hasError) return const Center(child: Text('Unable to load communities right now.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return const _Empty(icon: Icons.groups_outlined, title: 'Build your community', subtitle: 'Create or join spaces around football, finance, shopping, education and more.');
      return ListView.separated(
        padding: const EdgeInsets.all(16), itemCount: docs.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final d = docs[i].data(); final id = docs[i].id;
          return Card(color: const Color(0xFF111720), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF2563EB)])), child: const Icon(Icons.groups, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d['name']?.toString() ?? 'Community', style: const TextStyle(fontWeight: FontWeight.w900)),
              Text('${d['category'] ?? 'General'} • ${d['memberCount'] ?? 0} members', style: const TextStyle(color: Colors.white60)),
              const SizedBox(height: 4), Text(d['description']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54)),
            ])),
            const SizedBox(width: 8),
            Column(children: [TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommunityDetailPage(communityId: id, data: d))), child: const Text('Open')), _FollowButton(service: service, communityId: id)]),
          ])));
        },
      );
    },
  );

  Widget _creatorHubs() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: service.creatorHubs(),
    builder: (context, snap) {
      if (snap.hasError) return const Center(child: Text('Unable to load creator hubs right now.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      return Stack(children: [
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), itemCount: docs.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) { final d = docs[i].data(); return Card(color: const Color(0xFF111720), child: ListTile(leading: const CircleAvatar(child: Icon(Icons.auto_awesome)), title: Text(d['name']?.toString() ?? 'Creator hub', style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('${d['category'] ?? 'Creator'} • ${d['memberCount'] ?? 0} members\n${d['description'] ?? ''}'), trailing: const Icon(Icons.chevron_right))); },
        ),
        Positioned(right: 18, bottom: 18, child: FloatingActionButton.extended(onPressed: _createHub, icon: const Icon(Icons.add), label: const Text('Create hub'))),
      ]);
    },
  );

  Future<void> _createHub() async {
    final name = TextEditingController(); final description = TextEditingController(); String category = 'Lifestyle';
    await showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setModal) => AlertDialog(
      title: const Text('Create creator hub'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')), TextField(controller: description, decoration: const InputDecoration(labelText: 'Description')), DropdownButtonFormField<String>(value: category, items: const ['Football','Finance','Crypto','Shopping','Education','Lifestyle','Entertainment','Travel','Business'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setModal(() => category = v ?? category))]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async { await service.createCreatorHub(name: name.text, description: description.text, category: category); if (context.mounted) Navigator.pop(context); }, child: const Text('Submit'))],
    )));
    name.dispose(); description.dispose();
  }
}

class _FollowButton extends StatelessWidget {
  final GlobalCommunityService service; final String communityId;
  const _FollowButton({required this.service, required this.communityId});
  @override Widget build(BuildContext context) => StreamBuilder<bool>(stream: service.isFollowingCommunity(communityId), builder: (_, snap) { final following = snap.data ?? false; return OutlinedButton(onPressed: () => following ? service.unfollowCommunity(communityId) : service.followCommunity(communityId), child: Text(following ? 'Following' : 'Follow')); });
}

class _Empty extends StatelessWidget { final IconData icon; final String title; final String subtitle; const _Empty({required this.icon, required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 58, color: Colors.white30), const SizedBox(height: 14), Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54))]))); }
