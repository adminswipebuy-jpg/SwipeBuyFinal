import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/community_service.dart';

class CommunityDetailPage extends StatefulWidget {
  final String communityId;
  final Map<String, dynamic> data;
  const CommunityDetailPage({super.key, required this.communityId, required this.data});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  final service = CommunityService();
  final postController = TextEditingController();
  bool posting = false;

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  Future<void> _publishPost() async {
    final text = postController.text.trim();
    if (text.isEmpty) return;
    setState(() => posting = true);
    try {
      await service.createPost(communityId: widget.communityId, text: text);
      postController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } finally {
      if (mounted) setState(() => posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.data['name']?.toString() ?? 'Community';
    final category = widget.data['category']?.toString() ?? 'General';
    final description = widget.data['description']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900))),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: service.membership(widget.communityId),
        builder: (context, membershipSnap) {
          final joined = membershipSnap.data?.exists ?? false;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFFFF7A18), Color(0xFF10B981)])),
                          child: const Icon(Icons.groups, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                          Text('$category • ${widget.data['memberCount'] ?? 0} members', style: const TextStyle(color: Colors.white60)),
                        ])),
                        FilledButton(
                          onPressed: () => joined ? service.leave(widget.communityId) : service.join(widget.communityId),
                          child: Text(joined ? 'Joined' : 'Join'),
                        ),
                      ]),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(description, style: const TextStyle(color: Colors.white70)),
                      ],
                    ]),
                  ),
                ),
              ),
              if (joined)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(children: [
                    const Text('Community feed', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    const Spacer(),
                    Text('${widget.data['memberCount'] ?? 0} members', style: const TextStyle(color: Colors.white54)),
                  ]),
                )
              else
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text('Join the community to post, react and participate.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: service.posts(widget.communityId),
                  builder: (context, snap) {
                    if (snap.hasError) return const Center(child: Text('Community feed is unavailable.'));
                    if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                    final docs = snap.data!.docs;
                    if (docs.isEmpty) return const Center(child: Text('No posts yet. Start the conversation.'));
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final d = docs[i].data();
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                const CircleAvatar(radius: 17, child: Icon(Icons.person, size: 18)),
                                const SizedBox(width: 10),
                                Expanded(child: Text(d['authorName']?.toString() ?? 'SwipeBuy member', style: const TextStyle(fontWeight: FontWeight.w800))),
                              ]),
                              const SizedBox(height: 10),
                              Text(d['text']?.toString() ?? '', style: const TextStyle(height: 1.35)),
                              const SizedBox(height: 10),
                              Row(children: [
                                const Icon(Icons.favorite_border, size: 18, color: Colors.white54),
                                const SizedBox(width: 6),
                                Text('${d['likes'] ?? 0}', style: const TextStyle(color: Colors.white54)),
                                const SizedBox(width: 18),
                                const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white54),
                                const SizedBox(width: 6),
                                Text('${d['comments'] ?? 0}', style: const TextStyle(color: Colors.white54)),
                              ]),
                            ]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (joined)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                    child: Row(children: [
                      Expanded(child: TextField(controller: postController, minLines: 1, maxLines: 4, decoration: const InputDecoration(hintText: 'Share with your community...', filled: true))),
                      const SizedBox(width: 6),
                      IconButton.filled(onPressed: posting ? null : _publishPost, icon: posting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send)),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
