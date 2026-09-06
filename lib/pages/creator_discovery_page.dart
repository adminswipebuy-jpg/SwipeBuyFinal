import 'package:flutter/material.dart';
import '../services/creator_discovery_service.dart';
import 'creator_profile_page.dart';

class CreatorDiscoveryPage extends StatefulWidget {
  const CreatorDiscoveryPage({super.key});
  @override
  State<CreatorDiscoveryPage> createState() => _CreatorDiscoveryPageState();
}

class _CreatorDiscoveryPageState extends State<CreatorDiscoveryPage> {
  final _service = CreatorDiscoveryService();
  final _search = TextEditingController();
  String _category = 'All';

  static const _categories = ['All', 'Education', 'Fashion', 'Food', 'Fitness', 'Finance', 'Travel', 'Technology', 'Entertainment', 'Lifestyle'];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openCreator(CreatorDiscoveryItem item) => Navigator.push(context, MaterialPageRoute(builder: (_) => CreatorProfilePage(creatorId: item.id)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Discover Creators', style: TextStyle(fontWeight: FontWeight.w900))),
    body: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search creators, topics or usernames',
            suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.clear)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      SizedBox(
        height: 48,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => ChoiceChip(
            label: Text(_categories[i]),
            selected: _category == _categories[i],
            onSelected: (_) => setState(() => _category = _categories[i]),
          ),
        ),
      ),
      const Divider(height: 1),
      Expanded(
        child: StreamBuilder<List<CreatorDiscoveryItem>>(
          stream: _service.discover(query: _search.text, category: _category),
          builder: (context, snap) {
            if (snap.hasError) return const Center(child: Text('Unable to load creators right now.'));
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final creators = snap.data!;
            if (creators.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No creators found. Try another search or category.', textAlign: TextAlign.center)));
            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                itemCount: creators.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _CreatorCard(item: creators[i], onOpen: () => _openCreator(creators[i]), service: _service),
              ),
            );
          },
        ),
      ),
    ]),
  );
}

class _CreatorCard extends StatelessWidget {
  final CreatorDiscoveryItem item;
  final VoidCallback onOpen;
  final CreatorDiscoveryService service;
  const _CreatorCard({required this.item, required this.onOpen, required this.service});

  String _compact(int n) => n >= 1000000 ? '${(n / 1000000).toStringAsFixed(1)}M' : n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF111720),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(28),
          child: CircleAvatar(
            radius: 27,
            backgroundImage: item.avatarUrl.isNotEmpty ? NetworkImage(item.avatarUrl) : null,
            child: item.avatarUrl.isEmpty ? const Icon(Icons.person_outline, size: 28) : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: InkWell(
          onTap: onOpen,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              if (item.verified) const Padding(padding: EdgeInsets.only(left: 5), child: Icon(Icons.verified, size: 17, color: Color(0xFF38D9A9))),
            ]),
            const SizedBox(height: 4),
            Text('${_compact(item.followers)} followers • ${item.category}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 5),
            Text(item.bio, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
          ]),
        )),
        const SizedBox(width: 8),
        StreamBuilder<bool>(
          stream: service.isFollowing(item.id),
          builder: (_, snap) {
            final following = snap.data == true;
            return OutlinedButton(
              onPressed: () => service.toggleFollow(item.id),
              child: Text(following ? 'Following' : 'Follow'),
            );
          },
        ),
      ]),
    ),
  );
}
