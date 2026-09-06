import 'package:flutter/material.dart';
import '../services/personalization_hub_service.dart';

class PersonalizationHubPage extends StatefulWidget {
  const PersonalizationHubPage({super.key});

  @override
  State<PersonalizationHubPage> createState() => _PersonalizationHubPageState();
}

class _PersonalizationHubPageState extends State<PersonalizationHubPage> {
  final service = PersonalizationHubService();
  late Future<List<PersonalizationHubSection>> _future;

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
        title: const Text('For You Hub'),
        actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))],
      ),
      body: FutureBuilder<List<PersonalizationHubSection>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Could not load your picks: ${snapshot.error}'));
          final sections = snapshot.data ?? const <PersonalizationHubSection>[];
          if (sections.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(children: const [SizedBox(height: 140), Center(child: Text('Explore SwipeBuy to personalize your picks.'))]),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: const [
                        CircleAvatar(child: Icon(Icons.auto_awesome)),
                        SizedBox(width: 12),
                        Expanded(child: Text('Your SwipeBuy world, personalized across products, opportunities, places, services and content.', style: TextStyle(fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ...sections.expand((section) => [
                      Text(section.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(section.description, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: section.items.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (_, index) {
                            final item = section.items[index];
                            return SizedBox(
                              width: 230,
                              child: Card(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => service.recordSignal(itemId: item.id, type: item.type, signal: 'open'),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Chip(label: Text(item.type)),
                                      const SizedBox(height: 4),
                                      Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 6),
                                      Text('${item.category} • ${item.subtitle}', maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ]),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 22),
                    ]),
              ],
            ),
          );
        },
      ),
    );
  }
}
