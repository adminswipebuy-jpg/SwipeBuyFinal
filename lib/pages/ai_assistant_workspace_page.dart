import 'package:flutter/material.dart';
import '../services/ai_assistant_workspace_service.dart';
import '../services/universal_ai_service.dart';

class AiAssistantWorkspacePage extends StatefulWidget {
  const AiAssistantWorkspacePage({super.key});

  @override
  State<AiAssistantWorkspacePage> createState() => _AiAssistantWorkspacePageState();
}

class _AiAssistantWorkspacePageState extends State<AiAssistantWorkspacePage> {
  final _controller = TextEditingController();
  final _ai = UniversalAiService();
  final _workspace = AiAssistantWorkspaceService();
  List<UniversalAiResult> _results = const [];
  List<AiAssistantHistoryItem> _history = const [];
  List<String> _actions = const [];
  String _intent = 'Discovery';
  bool _busy = false;
  String _message = 'Tell SwipeBuy what you need. I can search across the app and suggest the next step.';

  final _examples = const [
    'Find me a good phone under GHS 4,000',
    'Find remote jobs for me',
    'Show apartments in Accra',
    'Plan a weekend trip',
    'Teach me forex basics',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final items = await _workspace.recentHistory();
    if (mounted) setState(() => _history = items);
  }

  Future<void> _ask([String? preset]) async {
    final prompt = (preset ?? _controller.text).trim();
    if (prompt.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _controller.text = prompt;
      _intent = _workspace.detectIntent(prompt);
      _actions = _workspace.nextActions(prompt);
      _message = 'Thinking and searching SwipeBuy…';
    });
    await _workspace.savePrompt(prompt);
    try {
      final results = await _ai.answer(prompt, limit: 20);
      if (!mounted) return;
      setState(() {
        _results = results;
        _message = results.isEmpty
            ? 'No strong match yet. Try adding a location, budget, category or keyword.'
            : 'I found ${results.length} relevant result${results.length == 1 ? '' : 's'} for you.';
      });
      await _loadHistory();
    } catch (_) {
      if (mounted) setState(() => _message = 'SwipeBuy Assistant is temporarily unavailable.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwipeBuy AI Assistant'),
        actions: [
          IconButton(
            tooltip: 'Clear',
            onPressed: () => setState(() {
              _controller.clear();
              _results = const [];
              _actions = const [];
              _intent = 'Discovery';
              _message = 'Tell SwipeBuy what you need. I can search across the app and suggest the next step.';
            }),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            _hero(),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _ask(),
              decoration: InputDecoration(
                hintText: 'Ask SwipeBuy anything…',
                prefixIcon: const Icon(Icons.auto_awesome),
                suffixIcon: IconButton(
                  onPressed: _busy ? null : () => _ask(),
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
                filled: true,
                fillColor: const Color(0xFF121720),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _examples.map((e) => ActionChip(label: Text(e), onPressed: () => _ask(e))).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _pill(_intent, Icons.route_outlined),
                const SizedBox(width: 8),
                if (_results.isNotEmpty) _pill('${_results.length} matches', Icons.search),
              ],
            ),
            if (_busy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator(minHeight: 2)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(_message, style: const TextStyle(color: Colors.white60, height: 1.35)),
            ),
            if (_actions.isNotEmpty) ...[
              const Text('Next best actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _actions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => OutlinedButton.icon(
                    onPressed: () => _ask('${_controller.text} — ${_actions[i]}'),
                    icon: const Icon(Icons.bolt_outlined, size: 18),
                    label: Text(_actions[i]),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_results.isNotEmpty) ...[
              const Text('Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ..._results.map((r) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF10B981).withOpacity(.18),
                    backgroundImage: r.imageUrl != null ? NetworkImage(r.imageUrl!) : null,
                    child: r.imageUrl == null ? const Icon(Icons.auto_awesome) : null,
                  ),
                  title: Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${r.type} • ${r.subtitle}', maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: FilledButton(onPressed: () {}, child: Text(r.action)),
                ),
              )),
            ],
            if (_results.isEmpty && _history.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Text('Recent conversations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ..._history.map((h) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(h.prompt, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(h.intent),
                  onTap: () => _ask(h.prompt),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _hero() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(colors: [Color(0xFF16251E), Color(0xFF11161E)]),
      border: Border.all(color: Colors.white10),
    ),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(radius: 24, child: Icon(Icons.auto_awesome)),
        SizedBox(width: 12),
        Expanded(child: Text('Your SwipeBuy co-pilot', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900))),
      ]),
      SizedBox(height: 10),
      Text('Search, compare, discover and prepare your next action across products, jobs, property, travel, learning, finance and services.', style: TextStyle(color: Colors.white70, height: 1.4)),
    ]),
  );

  Widget _pill(String text, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.06), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(text, style: const TextStyle(fontWeight: FontWeight.w700))]),
  );
}
