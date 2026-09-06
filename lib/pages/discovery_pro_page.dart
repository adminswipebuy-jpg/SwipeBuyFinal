import 'package:flutter/material.dart';
import '../services/discovery_pro_service.dart';

class DiscoveryProPage extends StatefulWidget {
  const DiscoveryProPage({super.key});

  @override
  State<DiscoveryProPage> createState() => _DiscoveryProPageState();
}

class _DiscoveryProPageState extends State<DiscoveryProPage> {
  final service = DiscoveryProService();
  final searchController = TextEditingController();
  String? category;
  String? action;
  double? radiusKm;

  Future<void> _runSearch() async {
    setState(() {});
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: (_) => _runSearch(),
              decoration: InputDecoration(
                hintText: 'Search jobs, food, hotels, services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    searchController.clear();
                    _runSearch();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _filter('All', null, null),
                _filter('Jobs', 'Jobs', 'hire'),
                _filter('Food', 'Food', 'order'),
                _filter('Hotels', 'Hotels', 'book'),
                _filter('Beauty', 'Beauty', 'book'),
                _filter('Services', 'Services', 'hire'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: service.search(
                query: searchController.text,
                category: category,
                action: action,
                radiusKm: radiusKm,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Search is temporarily unavailable.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!;
                if (docs.isEmpty) {
                  return const Center(child: Text('No matching opportunities yet.'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data();
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.play_circle_fill),
                        title: Text(data['title']?.toString() ?? 'SwipeBuy listing'),
                        subtitle: Text(
                          '${data['category'] ?? 'Marketplace'} • ${data['locationName'] ?? 'Worldwide'}',
                        ),
                        trailing: Text(data['actionLabel']?.toString() ?? 'View'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filter(String label, String? cat, String? act) {
    final selected = category == cat && action == act;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            category = cat;
            action = act;
          });
        },
      ),
    );
  }
}
