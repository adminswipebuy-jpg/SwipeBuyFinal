import 'package:flutter/material.dart';
import '../services/universal_ai_service.dart';

class AskSwipeBuyPage extends StatefulWidget {
  const AskSwipeBuyPage({super.key});

  @override
  State<AskSwipeBuyPage> createState() => _AskSwipeBuyPageState();
}

class _AskSwipeBuyPageState extends State<AskSwipeBuyPage> {
  final _controller = TextEditingController();
  final _service = UniversalAiService();
  final _examples = const [
    'Find phones under GHS 4,000',
    'Find jobs in Ghana',
    'Show houses in Accra',
    'What is happening in football?',
    'Help me learn forex',
    'Find a hotel for my trip',
  ];

  bool _loading = false;
  String _message = 'Ask SwipeBuy to find things across the whole platform.';
  List<UniversalAiResult> _results = [];

  Future<void> _ask([String? preset]) async {
    final value = (preset ?? _controller.text).trim();
    if (value.isEmpty || _loading) return;
    _controller.text = value;
    setState(() { _loading = true; _message = 'Searching SwipeBuy…'; });
    try {
      final results = await _service.answer(value);
      if (!mounted) return;
      setState(() {
        _results = results;
        _message = results.isEmpty
            ? 'I could not find a matching result yet. Try a simpler search or a different category.'
            : 'Here are the best matches I found.';
      });
    } catch (_) {
      if (mounted) setState(() => _message = 'SwipeBuy search is temporarily unavailable.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask SwipeBuy'),
        actions: [
          IconButton(
            tooltip: 'Clear',
            onPressed: () => setState(() { _controller.clear(); _results = []; _message = 'Ask SwipeBuy to find things across the whole platform.'; }),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(colors: [Color(0xFF17231F), Color(0xFF121720)]),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [Color(0xFFFF7A18), Color(0xFF10B981)]),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Ask SwipeBuy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
                ]),
                const SizedBox(height: 12),
                const Text(
                  'One search for products, jobs, property, sports, finance, education, travel and more.',
                  style: TextStyle(color: Colors.white70, height: 1.35),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _ask(),
              decoration: InputDecoration(
                hintText: 'What are you looking for?',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(onPressed: _loading ? null : () => _ask(), icon: const Icon(Icons.arrow_upward_rounded)),
                filled: true,
                fillColor: const Color(0xFF121720),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _examples.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ActionChip(label: Text(_examples[i]), onPressed: () => _ask(_examples[i])),
              ),
            ),
            const SizedBox(height: 18),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_message, style: const TextStyle(color: Colors.white60)),
            ),
            ..._results.map((result) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF10B981).withValues(alpha: .18),
                  backgroundImage: result.imageUrl != null ? NetworkImage(result.imageUrl!) : null,
                  child: result.imageUrl == null ? const Icon(Icons.auto_awesome) : null,
                ),
                title: Text(result.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${result.type} • ${result.subtitle}', maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: FilledButton(
                  onPressed: () {},
                  child: Text(result.action),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
