import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/realtime_chat_service.dart';
import '../services/community_service.dart';
import '../pages/rich_chat_page.dart';
import '../pages/following_pulse_page.dart';
import '../pages/community_detail_page.dart';

class CommunicationsPage extends StatefulWidget {
  const CommunicationsPage({super.key});
  @override State<CommunicationsPage> createState() => _CommunicationsPageState();
}

class _CommunicationsPageState extends State<CommunicationsPage> with SingleTickerProviderStateMixin {
  late final TabController tabs = TabController(length: 3, vsync: this);
  final chat = RealtimeChatService();
  final community = CommunityService();

  @override
  void dispose() { tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Connect', style: TextStyle(fontWeight: FontWeight.w900)),
      actions: [IconButton(onPressed: () => showSearch(context: context, delegate: _CommunicationSearchDelegate()), icon: const Icon(Icons.search))],
      bottom: TabBar(controller: tabs, tabs: const [Tab(text: 'Chats'), Tab(text: 'Communities'), Tab(text: 'Following')]),
    ),
    body: TabBarView(controller: tabs, children: [
      _ChatsTab(service: chat),
      _CommunitiesTab(service: community),
      const _FollowingPulseTab(),
    ]),
  );
}

class _ChatsTab extends StatelessWidget {
  final RealtimeChatService service;
  const _ChatsTab({required this.service});
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: service.conversations(),
    builder: (context, snap) {
      if (snap.hasError) return const Center(child: Text('Unable to load chats.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return const _EmptyState(icon: Icons.chat_bubble_outline, title: 'Start a conversation', subtitle: 'Message creators, sellers, professionals and friends.');
      return ListView.separated(
        padding: const EdgeInsets.all(16), itemCount: docs.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final d = docs[i].data();
          final members = List<String>.from(d['memberIds'] ?? const []);
          final other = members.firstWhere((x) => x != service.uid, orElse: () => '');
          return Card(color: const Color(0xFF111720), child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(d['title']?.toString() ?? 'Conversation', style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(d['lastMessage']?.toString() ?? 'Say hello'),
            trailing: const Icon(Icons.chevron_right),
            onTap: other.isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => RichChatPage(otherUserId: other, title: d['title']?.toString() ?? 'Chat')),
          )));
        },
      );
    },
  );
}

class _CommunitiesTab extends StatelessWidget {
  final CommunityService service;
  const _CommunitiesTab({required this.service});
  @override
  Widget build(BuildContext context) => Stack(children: [
    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: service.discover(),
      builder: (context, snap) {
        if (snap.hasError) return const Center(child: Text('Unable to load communities.'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) return const _EmptyState(icon: Icons.groups_outlined, title: 'Find your people', subtitle: 'Join communities around football, finance, education, shopping and more.');
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final d = docs[i].data(); final id = docs[i].id;
            return Card(color: const Color(0xFF111720), child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommunityDetailPage(communityId: id, data: d))),
              child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFFFF7A18), Color(0xFF10B981)])), child: const Icon(Icons.groups, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d['name']?.toString() ?? 'Community', style: const TextStyle(fontWeight: FontWeight.w900)),
                  Text('${d['category'] ?? 'General'} • ${d['memberCount'] ?? 0} members', style: const TextStyle(color: Colors.white60)),
                  const SizedBox(height: 4), Text(d['description']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54)),
                ])),
                const SizedBox(width: 8), FilledButton(onPressed: () => service.join(id), child: const Text('Join')),
              ]),
            )),
        );},
        );
      },
    ),
    Positioned(right: 18, bottom: 18, child: FloatingActionButton.extended(onPressed: () => _createCommunity(context), icon: const Icon(Icons.add), label: const Text('Create'))),
  ]);

  Future<void> _createCommunity(BuildContext context) async {
    final name = TextEditingController(); final desc = TextEditingController(); String category = 'Lifestyle';
    await showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setModal) => AlertDialog(
      title: const Text('Create community'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
        TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description')),
        DropdownButtonFormField<String>(initialValue: category, items: const ['Football','Finance','Crypto','Jobs','Education','Lifestyle','Shopping'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setModal(() => category = v ?? category)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async { await service.createCommunity(name: name.text, description: desc.text, category: category); if (context.mounted) Navigator.pop(context); }, child: const Text('Create'))],
    )));
    name.dispose(); desc.dispose();
  }
}

class _FollowingPulseTab extends StatelessWidget {
  const _FollowingPulseTab();
  @override
  Widget build(BuildContext context) => Center(child: FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowingPulsePage())), icon: const Icon(Icons.auto_awesome), label: const Text('Open Following Pulse')));
}

class _EmptyState extends StatelessWidget {
  final IconData icon; final String title; final String subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 58, color: Colors.white30), const SizedBox(height: 14), Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54))])));
}

class _CommunicationSearchDelegate extends SearchDelegate<String> {
  @override List<Widget>? buildActions(BuildContext context) => [IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))];
  @override Widget? buildLeading(BuildContext context) => IconButton(onPressed: () => close(context, ''), icon: const Icon(Icons.arrow_back));
  @override Widget buildResults(BuildContext context) => const _EmptyState(icon: Icons.search, title: 'Search is ready', subtitle: 'We will connect this to global people, communities and content search next.');
  @override Widget buildSuggestions(BuildContext context) => const _EmptyState(icon: Icons.travel_explore, title: 'Find your world', subtitle: 'Search people, communities, creators and conversations.');
}
