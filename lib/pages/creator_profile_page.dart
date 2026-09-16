import 'package:flutter/material.dart';
import '../services/creator_content_service.dart';
import '../services/creator_profile_service.dart';
import '../services/content_feed_service.dart';
import 'video_player_page.dart';

class CreatorProfilePage extends StatefulWidget {
  final String creatorId;
  const CreatorProfilePage({super.key, required this.creatorId});

  @override
  State<CreatorProfilePage> createState() => _CreatorProfilePageState();
}

class _CreatorProfilePageState extends State<CreatorProfilePage> {
  final profileService = CreatorProfileService();
  final social = CreatorContentService();
  late Future<Map<String, dynamic>> profileFuture;

  @override
  void initState() {
    super.initState();
    profileFuture = profileService.getProfile(widget.creatorId);
  }

  String compact(int n) => n >= 1000000 ? '${(n / 1000000).toStringAsFixed(1)}M' : n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creator'), centerTitle: true),
      body: FutureBuilder<Map<String, dynamic>>(
        future: profileFuture,
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final p = snap.data!;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Column(children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundImage: (p['avatarUrl']?.toString().isNotEmpty ?? false) ? NetworkImage(p['avatarUrl']) : null,
                    child: p['avatarUrl'] == null ? const Icon(Icons.person, size: 40) : null,
                  ),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(p['displayName'].toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    if (p['verified'] == true) ...[const SizedBox(width: 5), const Icon(Icons.verified, size: 20, color: Color(0xFF38D9A9))],
                  ]),
                  const SizedBox(height: 6),
                  Text(p['bio'].toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _Stat(label: 'Followers', value: compact((p['followers'] as num?)?.toInt() ?? 0)),
                    const SizedBox(width: 30),
                    _Stat(label: 'Following', value: compact((p['following'] as num?)?.toInt() ?? 0)),
                  ]),
                  const SizedBox(height: 14),
                  StreamBuilder<bool>(
                    stream: social.isFollowing(widget.creatorId),
                    builder: (_, s) => SizedBox(width: 180, child: FilledButton(
                      onPressed: () => social.toggleFollow(widget.creatorId),
                      child: Text(s.data == true ? 'Following' : 'Follow'),
                    )),
                  ),
                ]),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                child: Text('Posts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              )),
              StreamBuilder(
                stream: profileService.posts(widget.creatorId),
                builder: (_, snap) {
                  if (!snap.hasData) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                  final docs = snap.data!.docs;
                  if (docs.isEmpty) return const SliverFillRemaining(child: Center(child: Text('No published posts yet.')));
                  final items = docs.map((d) => ContentItem.fromMap(d.id, d.data())).toList();
                  return SliverPadding(
                    padding: const EdgeInsets.all(14),
                    sliver: SliverGrid.builder(
                      itemCount: items.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: .75),
                      itemBuilder: (_, i) => InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FullContentPreview(item: items[i]))),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(fit: StackFit.expand, children: [
                            Container(color: const Color(0xFF121720), child: const Icon(Icons.play_circle_outline, size: 54)),
                            if (items[i].imageUrl != null) Image.network(items[i].imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                            Positioned(left: 8, right: 8, bottom: 8, child: Text(items[i].title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800))),
                          ]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: Colors.white60))]);
}

class FullContentPreview extends StatelessWidget {
  final ContentItem item;
  const FullContentPreview({super.key, required this.item});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(item.creator)),
    body: Stack(children: [
      Positioned.fill(child: item.contentType == 'video' && item.imageUrl != null ? VideoPlayerPage(item: item) : Center(child: Padding(padding: const EdgeInsets.all(20), child: Text(item.summary, style: const TextStyle(fontSize: 20))))),
      Positioned(left: 16, right: 16, bottom: 18, child: Text(item.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
    ]),
  );
}
