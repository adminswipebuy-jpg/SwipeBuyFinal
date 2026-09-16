import 'package:flutter/material.dart';
import '../services/social_feed_v2_service.dart';
import 'creator_profile_page.dart';
import 'product_detail_page.dart';

class FollowingPulsePage extends StatefulWidget {
  const FollowingPulsePage({super.key});

  @override
  State<FollowingPulsePage> createState() => _FollowingPulsePageState();
}

class _FollowingPulsePageState extends State<FollowingPulsePage> {
  final service = SocialFeedV2Service();
  late Future<List<SocialFeedV2Item>> future;

  @override
  void initState() {
    super.initState();
    future = service.loadPulse();
  }

  Future<void> refresh() async {
    setState(() => future = service.loadPulse());
    await future;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Following Pulse', style: TextStyle(fontWeight: FontWeight.w900)),
      actions: [IconButton(onPressed: refresh, icon: const Icon(Icons.refresh))],
    ),
    body: RefreshIndicator(
      onRefresh: refresh,
      child: FutureBuilder<List<SocialFeedV2Item>>(
        future: future,
        builder: (context, snap) {
          if (snap.hasError) return ListView(children: const [SizedBox(height: 180), Center(child: Text('Unable to load your following pulse.'))]);
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty) return ListView(children: const [SizedBox(height: 160), Icon(Icons.auto_awesome, size: 58, color: Colors.white24), SizedBox(height: 12), Center(child: Text('Follow creators, businesses and professionals to build your pulse.'))]);
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _PulseCard(item: items[i]),
          );
        },
      ),
    ),
  );
}

class _PulseCard extends StatelessWidget {
  final SocialFeedV2Item item;
  const _PulseCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final image = (item.data['mediaUrl'] ?? item.data['imageUrl'] ?? item.data['photoUrl'])?.toString();
    final isListing = item.type == 'listing';
    return Card(
      color: const Color(0xFF111720),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (image != null && image.isNotEmpty) SizedBox(height: 190, width: double.infinity, child: Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink())),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(child: Icon(isListing ? Icons.storefront_outlined : Icons.play_circle_outline)),
              const SizedBox(width: 10),
              Expanded(child: Text(isListing ? 'New marketplace update' : 'New post from someone you follow', style: const TextStyle(color: Colors.white60, fontSize: 12))),
              Chip(label: Text(isListing ? 'SHOP' : 'POST')),
            ]),
            const SizedBox(height: 10),
            Text(item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(item.subtitle, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, height: 1.25)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreatorProfilePage(creatorId: item.ownerId))), icon: const Icon(Icons.person_outline), label: const Text('View creator'))),
              const SizedBox(width: 8),
              if (isListing)
                Expanded(child: FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(productId: item.id, businessId: item.ownerId, title: 'product'))), icon: const Icon(Icons.shopping_bag_outlined), label: const Text('View'))),
            ]),
          ]),
        ),
      ]),
    );
  }
}
