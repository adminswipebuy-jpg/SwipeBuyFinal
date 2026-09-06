import 'package:flutter/material.dart';
import '../services/creator_publish_service.dart';
import '../services/story_engagement_service.dart';
import 'story_composer_page.dart';

class StoriesPage extends StatelessWidget {
  const StoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = CreatorPublishService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwipeBuy Stories'),
        actions: [
          IconButton(
            tooltip: 'Create story',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryComposerPage())),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryComposerPage())),
        icon: const Icon(Icons.camera_alt_outlined),
        label: const Text('Create'),
      ),
      body: StreamBuilder(
        stream: service.activeStories(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No active stories yet. Be the first to post one.'));
          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final d = docs[i].data();
              final title = d['creator']?.toString() ?? 'Creator';
              final url = d['mediaUrl']?.toString();
              return InkWell(
                onTap: () async {
                  await service.incrementStoryView(docs[i].id);
                  if (context.mounted && url != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => StoryViewerPage(
                      storyId: docs[i].id,
                      title: title,
                      mediaUrl: url,
                      caption: d['caption']?.toString() ?? '',
                    )));
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: [Color(0xFF151B25), Color(0xFF0C1118)]),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Spacer(),
                      CircleAvatar(radius: 22, child: Text(title.isNotEmpty ? title.characters.first.toUpperCase() : '?')),
                      const SizedBox(height: 10),
                      Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                      Text(d['caption']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text('${d['views'] ?? 0} views • 24-hour story', style: const TextStyle(color: Colors.white54)),
                      if ((d['category'] ?? '').toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text('• ${(d['category'] ?? 'General').toString()}', style: const TextStyle(color: Colors.white38)),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StoryViewerPage extends StatefulWidget {
  final String storyId;
  final String title;
  final String mediaUrl;
  final String caption;
  const StoryViewerPage({super.key, required this.storyId, required this.title, required this.mediaUrl, required this.caption});

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  final engagement = StoryEngagementService();
  final replyController = TextEditingController();

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  Future<void> reply() async {
    final text = replyController.text;
    if (text.trim().isEmpty) return;
    await engagement.reply(widget.storyId, text);
    replyController.clear();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reply sent')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.black),
    body: Stack(
      children: [
        Positioned.fill(child: Image.network(widget.mediaUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, size: 70)))),
        Positioned(
          left: 14,
          right: 14,
          bottom: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.caption.isNotEmpty)
                DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
                  child: Padding(padding: const EdgeInsets.all(14), child: Text(widget.caption, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
                ),
              const SizedBox(height: 10),
              StreamBuilder<String?>(
                stream: engagement.myReaction(widget.storyId),
                builder: (context, snap) => Row(
                  children: [
                    for (final reaction in ['❤️', '🔥', '😂', '👏'])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          selected: snap.data == reaction,
                          label: Text(reaction, style: const TextStyle(fontSize: 18)),
                          onSelected: (_) => engagement.react(widget.storyId, reaction),
                        ),
                      ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: replyController,
                onSubmitted: (_) => reply(),
                decoration: InputDecoration(
                  hintText: 'Reply to this story…',
                  filled: true,
                  fillColor: Colors.white10,
                  suffixIcon: IconButton(onPressed: reply, icon: const Icon(Icons.send)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
