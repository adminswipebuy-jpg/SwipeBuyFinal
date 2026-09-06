import 'package:flutter/material.dart';
import '../services/universal_ai_service.dart';
import '../services/voice_assistant_service.dart';
import 'ai_actions_page.dart';
import 'multimodal_ai_page.dart';

class AiCommandCenter2Page extends StatefulWidget {
  const AiCommandCenter2Page({super.key});

  @override
  State<AiCommandCenter2Page> createState() => _AiCommandCenter2PageState();
}

class _AiCommandCenter2PageState extends State<AiCommandCenter2Page> {
  final _prompt = TextEditingController();
  final _ai = UniversalAiService();
  final _voice = VoiceAssistantService();
  List<UniversalAiResult> _results = const [];
  bool _busy = false;
  bool _listening = false;
  String _status = 'Use text, voice or Vision AI. SwipeBuy will help you discover the next step.';

  final _prompts = const [
    'Find a phone under GHS 4,000',
    'Find remote jobs in Ghana',
    'Show apartments in Accra',
    'Plan a weekend trip',
  ];

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  Future<void> _ask([String? preset]) async {
    final text = (preset ?? _prompt.text).trim();
    if (text.isEmpty || _busy) return;
    setState(() {
      _prompt.text = text;
      _busy = true;
      _status = 'Searching SwipeBuy and ranking the best matches…';
    });
    try {
      final results = await _ai.answer(text, limit: 20);
      if (!mounted) return;
      setState(() {
        _results = results;
        _status = results.isEmpty
            ? 'No strong match yet. Add a location, budget or category.'
            : '${results.length} relevant result${results.length == 1 ? '' : 's'} found.';
      });
    } catch (_) {
      if (mounted) setState(() => _status = 'SwipeBuy AI is temporarily unavailable.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleVoice() async {
    if (_listening) {
      await _voice.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final ok = await _voice.initialize(onStatus: (status) {
      if (mounted) setState(() => _status = status);
    });
    if (!ok) {
      if (mounted) setState(() => _status = 'Microphone or speech recognition is unavailable.');
      return;
    }
    setState(() {
      _listening = true;
      _status = 'Listening…';
    });
    await _voice.listen(onResult: (result) {
      if (!mounted) return;
      setState(() => _prompt.text = result.recognizedWords);
      if (result.finalResult) {
        setState(() => _listening = false);
        _ask();
      }
    });
  }

  void _open(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwipeBuy AI 2.0'),
        actions: [
          IconButton(
            tooltip: 'Privacy & safety',
            onPressed: _showPrivacy,
            icon: const Icon(Icons.shield_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
          children: [
            _hero(),
            const SizedBox(height: 14),
            _input(),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _prompts.map((p) => ActionChip(label: Text(p), onPressed: () => _ask(p))).toList(),
            ),
            const SizedBox(height: 14),
            Text(_status, style: const TextStyle(color: Colors.white60, height: 1.35)),
            if (_busy) const Padding(padding: EdgeInsets.only(top: 10), child: LinearProgressIndicator(minHeight: 2)),
            const SizedBox(height: 18),
            const Text('AI tools', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _tool('Voice actions', Icons.mic_none_rounded, 'Talk and prepare actions', () => _open(const AiActionsPage()))),
              const SizedBox(width: 10),
              Expanded(child: _tool('Vision AI', Icons.image_search_outlined, 'Show SwipeBuy a photo', () => _open(const MultimodalAiPage()))),
            ]),
            const SizedBox(height: 18),
            if (_results.isNotEmpty) ...[
              const Text('Smart results', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ..._results.map((r) => Card(
                margin: const EdgeInsets.only(bottom: 9),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: r.imageUrl != null ? NetworkImage(r.imageUrl!) : null,
                    child: r.imageUrl == null ? const Icon(Icons.auto_awesome) : null,
                  ),
                  title: Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${r.type} • ${r.subtitle}', maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: FilledButton(onPressed: () {}, child: Text(r.action)),
                ),
              )),
            ] else ...[
              _modeCard(Icons.auto_awesome, 'Ask naturally', '“Find the best phone for me under GHS 4,000.”'),
              _modeCard(Icons.mic, 'Speak naturally', 'Use your voice for hands-free discovery and action planning.'),
              _modeCard(Icons.camera_alt_outlined, 'Show a photo', 'Find similar products, understand an image or start discovery from it.'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _hero() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26),
      gradient: const LinearGradient(colors: [Color(0xFF18261F), Color(0xFF111720)]),
      border: Border.all(color: Colors.white10),
    ),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(radius: 26, child: Icon(Icons.auto_awesome, size: 28)),
        SizedBox(width: 12),
        Expanded(child: Text('One AI command center', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
      ]),
      SizedBox(height: 10),
      Text('Search, speak, see and act across SwipeBuy. Sensitive purchases, bookings and account actions stay behind explicit confirmation and trusted backend controls.', style: TextStyle(color: Colors.white70, height: 1.4)),
    ]),
  );

  Widget _input() => Row(children: [
    Expanded(child: TextField(
      controller: _prompt,
      maxLines: 3,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _ask(),
      decoration: InputDecoration(
        hintText: 'Ask SwipeBuy anything…',
        prefixIcon: const Icon(Icons.auto_awesome),
        filled: true,
        fillColor: const Color(0xFF121720),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    )),
    const SizedBox(width: 8),
    Column(children: [
      IconButton.filled(onPressed: _busy ? null : _toggleVoice, icon: Icon(_listening ? Icons.stop : Icons.mic), tooltip: 'Voice'),
      IconButton.filledTonal(onPressed: _busy ? null : () => _ask(), icon: const Icon(Icons.arrow_upward_rounded), tooltip: 'Ask'),
    ]),
  ]);

  Widget _tool(String title, IconData icon, String subtitle, VoidCallback onTap) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF111720), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 28), const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.3)),
        ]),
      ),
    ),
  );

  Widget _modeCard(IconData icon, String title, String subtitle) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(leading: Icon(icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle)),
  );

  void _showPrivacy() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(18, 6, 18, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI privacy & safety', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          SizedBox(height: 10),
          Text('Voice input is used for speech recognition. Vision images are uploaded temporarily for the secured AI pipeline. Sensitive actions should be executed through trusted backend functions and require user confirmation.'),
        ]),
      ),
    );
  }
}
