import 'package:flutter/material.dart';
import '../services/global_search_intelligence_service.dart';

class GlobalSearchIntelligencePage extends StatefulWidget {
  const GlobalSearchIntelligencePage({super.key});

  @override
  State<GlobalSearchIntelligencePage> createState() => _GlobalSearchIntelligencePageState();
}

class _GlobalSearchIntelligencePageState extends State<GlobalSearchIntelligencePage> {
  final service = GlobalSearchIntelligenceService();
  final controller = TextEditingController();
  final modes = const ['All', 'Marketplace', 'Jobs', 'Property', 'Services', 'Content'];
  String mode = 'All';
  List<GlobalSearchResult> results = const [];
  List<String> suggestions = const [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    final items = await service.suggestions(controller.text);
    if (mounted) setState(() => suggestions = items);
  }

  Future<void> _search([String? value]) async {
    final text = (value ?? controller.text).trim();
    if (text.isEmpty) return;
    controller.text = text;
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    setState(() => loading = true);
    try {
      final found = await service.search(text, mode: mode);
      if (mounted) setState(() => results = found);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Intelligence')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onChanged: (_) => _loadSuggestions(),
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Ask SwipeBuy to find something…',
                prefixIcon: const Icon(Icons.auto_awesome),
                suffixIcon: IconButton(onPressed: () => _search(), icon: const Icon(Icons.search)),
                filled: true,
                fillColor: const Color(0xFF121720),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: modes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (_, i) => ChoiceChip(
                label: Text(modes[i]),
                selected: mode == modes[i],
                onSelected: (_) => setState(() => mode = modes[i]),
              ),
            ),
          ),
          if (controller.text.trim().isEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 18, 18, 10),
                child: Text('Try a smart search', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions.map((s) => ActionChip(label: Text(s), onPressed: () => _search(s))).toList(),
              ),
            ),
          ],
          if (loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: results.isEmpty && !loading
                ? const Center(child: Text('Search across products, jobs, property, services and content.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final item = results[i];
                      return Card(
                        color: const Color(0xFF111720),
                        child: ListTile(
                          leading: CircleAvatar(child: Icon(_iconFor(item.type))),
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text('${item.type} • ${item.category}\n${item.subtitle}', maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: Text(item.score.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'Jobs':
        return Icons.work_outline;
      case 'Property':
        return Icons.home_work_outlined;
      case 'Services':
        return Icons.handyman_outlined;
      case 'Content':
        return Icons.play_circle_outline;
      default:
        return Icons.storefront_outlined;
    }
  }
}
