import 'package:flutter/material.dart';
import '../services/content_feed_service.dart';
import '../services/creator_content_service.dart';
import '../services/personalization_service.dart';
import '../services/content_engagement_service.dart';
import '../services/feed_ranking_service.dart';
import 'creator_profile_page.dart';
import 'video_player_page.dart';

class ContentFeedView extends StatefulWidget {
  final String category;
  const ContentFeedView({super.key, required this.category});

  @override
  State<ContentFeedView> createState() => _ContentFeedViewState();
}

class _ContentFeedViewState extends State<ContentFeedView> {
  final service = ContentFeedService();
  final personalization = PersonalizationService();
  final ranking = FeedRankingService();
  late Future<List<ContentItem>> _future;
  String _mode = 'For You';
  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
    _future = widget.category == 'For You' ? _loadForYou() : service.load(category: widget.category);
  }

  @override
  void didUpdateWidget(covariant ContentFeedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _future = widget.category == 'For You' ? _loadForYou() : service.load(category: widget.category);
    }
  }


  Future<List<ContentItem>> _loadForYou() async {
    if (_mode == 'For You') {
      final rows = await personalization.personalizedContent();
      if (rows.isNotEmpty) return rows.map((x) => ContentItem.fromMap((x['_id'] ?? '').toString(), x)).toList();
    }
    final rows = await ranking.load(mode: _mode);
    if (rows.isEmpty) return service.load(category: 'For You');
    return rows.map((x) => ContentItem.fromMap((x['_id'] ?? '').toString(), x)).toList();
  }

  void _changeMode(String mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _future = widget.category == 'For You' ? _loadForYou() : service.load(category: widget.category);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _future = widget.category == 'For You' ? _loadForYou() : service.load(category: widget.category));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ContentItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nothing here yet. Swipe to explore more.'));
        }
        final items = snapshot.data!;
        return Column(
          children: [
            if (widget.category == 'For You')
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['For You', 'Trending', 'Fresh'].map((mode) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(mode),
                        selected: _mode == mode,
                        onSelected: (_) => _changeMode(mode),
                      ),
                    )).toList(),
                  ),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            itemCount: items.length,
            onPageChanged: (index) {
              final item = items[index];
              service.record(item.id, 'impression');
            },
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
              child: ContentCard(item: items[index], service: service),
            ),
            ),
          ),
        ],
      );
      },
    );
  }
}

class ContentCard extends StatefulWidget {
  final ContentItem item;
  final ContentFeedService service;
  const ContentCard({super.key, required this.item, required this.service});

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  final creatorService = CreatorContentService();
  final engagementService = ContentEngagementService();
  bool following = false;
  bool liked = false;

  ContentItem get item => widget.item;
  ContentFeedService get service => widget.service;

  IconData get icon {
    switch (item.category) {
      case 'Sports': return Icons.sports_soccer;
      case 'News': return Icons.newspaper;
      case 'Forex': return Icons.currency_exchange;
      case 'Crypto': return Icons.currency_bitcoin;
      case 'Investment': return Icons.trending_up;
      case 'Real Estate': return Icons.home_work;
      case 'Jobs': return Icons.work;
      case 'Education': return Icons.school;
      case 'Fitness': return Icons.fitness_center;
      case 'Lifestyle': return Icons.weekend;
      default: return Icons.auto_awesome;
    }
  }

  Color get accent {
    switch (item.category) {
      case 'Sports': return Colors.deepPurple;
      case 'News': return Colors.indigo;
      case 'Forex': return Colors.green;
      case 'Crypto': return Colors.orange;
      case 'Investment': return Colors.blue;
      case 'Real Estate': return Colors.teal;
      case 'Jobs': return Colors.indigoAccent;
      case 'Education': return Colors.lightBlue;
      case 'Fitness': return Colors.pink;
      case 'Lifestyle': return Colors.amber;
      default: return const Color(0xFF38D9A9);
    }
  }

  String compact(int value) => value >= 1000000
      ? '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M'
      : value >= 1000
          ? '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K'
          : '$value';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0D1219),
                  accent.withOpacity(.26),
                  const Color(0xFF05070A),
                ],
              ),
            ),
          ),
          Positioned.fill(child: item.contentType == 'video' && item.imageUrl != null
              ? VideoPlayerPage(item: item)
              : item.imageUrl != null
                ? Image.network(item.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _Artwork(icon: icon, accent: accent))
                : _Artwork(icon: icon, accent: accent)),
          Positioned(top: 16, left: 16, child: _Tag(label: item.category, icon: icon)),
          Positioned(top: 68, right: 10, child: Column(children: [
            _Action(icon: Icons.favorite, label: compact(item.likes), onTap: () async { await creatorService.toggleLike(item.id); if (mounted) setState(() => liked = !liked); await service.record(item.id, 'like'); }),
            _Action(icon: Icons.chat_bubble_outline, label: compact(item.comments), onTap: () => _showComments(context)),
            _Action(icon: Icons.share_outlined, label: compact(item.shares), onTap: () async { await engagementService.recordShare(item.id); await service.record(item.id, 'share'); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share link ready.'))); }),
            StreamBuilder<bool>(
              stream: engagementService.isSaved(item.id),
              builder: (_, snap) {
                final saved = snap.data == true;
                return _Action(icon: saved ? Icons.bookmark : Icons.bookmark_border, label: saved ? 'Saved' : 'Save', onTap: () async { await engagementService.toggleSave(item.id); await service.record(item.id, saved ? 'unsave' : 'save'); });
              },
            ),
            _Action(icon: Icons.more_horiz, label: 'More', onTap: () => _showMore(context)),
          ])),
          Positioned(
            left: 18,
            right: 64,
            bottom: 18,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(backgroundColor: accent.withOpacity(.22), child: Icon(icon, color: accent)),
                const SizedBox(width: 9),
                Expanded(child: InkWell(onTap: item.creatorId != null && item.creatorId!.isNotEmpty && item.creatorId != 'unknown' ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreatorProfilePage(creatorId: item.creatorId!))) : null, child: Text(item.creator, style: const TextStyle(fontWeight: FontWeight.w800)))),
                if (item.verified) const Icon(Icons.verified, color: Color(0xFF38D9A9), size: 18),
                if (item.creatorId != null && item.creatorId!.isNotEmpty && item.creatorId != 'unknown')
                  StreamBuilder<bool>(
                    stream: creatorService.isFollowing(item.creatorId!),
                    builder: (_, snap) => TextButton(
                      onPressed: () async { await creatorService.toggleFollow(item.creatorId!); },
                      child: Text(snap.data == true ? 'Following' : 'Follow'),
                    ),
                  ),
              ]),
              const SizedBox(height: 10),
              Text(item.title, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, height: 1.05)),
              const SizedBox(height: 6),
              Text('• ${item.location}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 5),
              Text(item.summary, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, height: 1.25)),
              const SizedBox(height: 14),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: () => service.record(item.id, 'primary_action'),
                  child: Text(item.actionLabel, style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _showMore(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.visibility_outlined), title: const Text('Not interested'), subtitle: const Text('Tune future recommendations'), onTap: () { Navigator.pop(sheetContext); service.record(item.id, 'not_interested'); }),
          ListTile(leading: const Icon(Icons.flag_outlined), title: const Text('Report content'), subtitle: const Text('Send this post to moderation'), onTap: () async {
            Navigator.pop(sheetContext);
            await engagementService.reportContent(item.id, 'User reported from feed');
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks. The report was sent for review.')));
          }),
        ]),
      ),
    );
  }

  Future<void> _showComments(BuildContext context) async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * .65,
          child: Column(children: [
            const SizedBox(height: 14),
            const Text('Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Expanded(child: StreamBuilder(
              stream: creatorService.comments(item.id),
              builder: (_, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('Be the first to comment.'));
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final d = docs[i].data();
                    return ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text((d['userId'] ?? 'User').toString()), subtitle: Text((d['text'] ?? '').toString()));
                  },
                );
              },
            )),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Write a comment...', filled: true))),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async { final text = controller.text; await creatorService.addComment(item.id, text); controller.clear(); },
                  icon: const Icon(Icons.send),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  final IconData icon;
  final Color accent;
  const _Artwork({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _ArtworkPainter(icon: icon, accent: accent));
}

class _ArtworkPainter extends CustomPainter {
  final IconData icon;
  final Color accent;
  _ArtworkPainter({required this.icon, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()..color = accent.withOpacity(.10);
    canvas.drawCircle(Offset(size.width * .52, size.height * .30), size.width * .38, glow);
    final grid = Paint()..color = Colors.white.withOpacity(.035)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 44) canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (double y = 0; y < size.height; y += 44) canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    final tp = TextPainter(
      text: TextSpan(text: String.fromCharCode(icon.codePoint), style: TextStyle(fontSize: 190, fontFamily: icon.fontFamily, package: icon.fontPackage, color: accent.withOpacity(.20))),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, size.height * .17));
  }

  @override
  bool shouldRepaint(covariant _ArtworkPainter oldDelegate) => oldDelegate.icon != icon || oldDelegate.accent != accent;
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Tag({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white12)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label, style: const TextStyle(fontWeight: FontWeight.bold))]),
  );
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Column(children: [Icon(icon, size: 28), const SizedBox(height: 3), Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))]),
    ),
  );
}
