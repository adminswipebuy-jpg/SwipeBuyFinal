import 'package:flutter/material.dart';
import '../services/ai_recommendation_service.dart';

class AiFeedPage extends StatefulWidget {
  const AiFeedPage({super.key});

  @override
  State<AiFeedPage> createState() => _AiFeedPageState();
}

class _AiFeedPageState extends State<AiFeedPage> {
  final service = AiRecommendationService();
  String? category;

  Future<void> refresh() async => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('For You'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => category = value == 'All' ? null : value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'Jobs', child: Text('Jobs')),
              PopupMenuItem(value: 'Food', child: Text('Food')),
              PopupMenuItem(value: 'Hotels', child: Text('Hotels')),
              PopupMenuItem(value: 'Beauty', child: Text('Beauty')),
              PopupMenuItem(value: 'Services', child: Text('Services')),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: service.rankedFeed(category: category),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Your personalized feed is temporarily unavailable.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!;
          if (docs.isEmpty) {
            return const Center(child: Text('Explore more on SwipeBuy to personalize your feed.'));
          }
          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final data = docs[i].data();
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: ListTile(
                    leading: const Icon(Icons.auto_awesome),
                    title: Text(data['title']?.toString() ?? 'SwipeBuy opportunity'),
                    subtitle: Text(
                      '${data['category'] ?? 'Marketplace'} • ${data['locationName'] ?? 'Worldwide'}',
                    ),
                    trailing: Text(data['actionLabel']?.toString() ?? 'View'),
                    onTap: () => service.recordRecommendationSignal(
                      listingId: docs[i].id,
                      signal: 'recommendation_click',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
