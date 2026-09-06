import 'package:flutter/material.dart';
import '../services/smart_recommendations_service.dart';

class SmartRecommendationsPage extends StatefulWidget {
  const SmartRecommendationsPage({super.key});

  @override
  State<SmartRecommendationsPage> createState() => _SmartRecommendationsPageState();
}

class _SmartRecommendationsPageState extends State<SmartRecommendationsPage> {
  final service = SmartRecommendationsService();
  late Future<List<SmartRecommendationItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = service.load();
  }

  Future<void> _refresh() async {
    setState(() => _future = service.load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Recommendations'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<SmartRecommendationItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Could not load recommendations: ${snapshot.error}'));
          }
          final items = snapshot.data ?? const <SmartRecommendationItem>[];
          if (items.isEmpty) {
            return const Center(child: Text('No recommendations yet. Explore SwipeBuy to personalize your feed.'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = items[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: SizedBox(
                      width: 58,
                      height: 58,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: item.imageUrl == null
                            ? const ColoredBox(
                                color: Color(0xFF18212B),
                                child: Icon(Icons.auto_awesome),
                              )
                            : Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const ColoredBox(
                                  color: Color(0xFF18212B),
                                  child: Icon(Icons.auto_awesome),
                                ),
                              ),
                      ),
                    ),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('${item.category} • ${item.subtitle}', maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await service.recordSignal(recommendationId: item.id, signal: 'open');
                    },
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
