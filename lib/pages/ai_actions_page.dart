import 'package:flutter/material.dart';
import '../services/ai_action_service.dart';
import '../services/voice_assistant_service.dart';
import 'ask_swipebuy_page.dart';
import 'multimodal_ai_page.dart';
import 'ai_command_center_2_page.dart';

class AiActionsPage extends StatefulWidget {
  const AiActionsPage({super.key});
  @override
  State<AiActionsPage> createState() => _AiActionsPageState();
}

class _AiActionsPageState extends State<AiActionsPage> {
  final _prompt = TextEditingController();
  final _voice = VoiceAssistantService();
  final _actions = AiActionService();
  bool _listening = false;
  bool _busy = false;
  String _voiceStatus = 'Tap the microphone and speak to SwipeBuy.';
  AiActionPlan? _plan;

  @override
  void dispose() { _prompt.dispose(); super.dispose(); }

  Future<void> _toggleVoice() async {
    if (_listening) {
      await _voice.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final ok = await _voice.initialize(onStatus: (status) {
      if (mounted) setState(() => _voiceStatus = status);
    });
    if (!ok) {
      if (mounted) setState(() => _voiceStatus = 'Microphone or speech recognition is unavailable.');
      return;
    }
    setState(() { _listening = true; _voiceStatus = 'Listening…'; });
    await _voice.listen(onResult: (result) {
      setState(() => _prompt.text = result.recognizedWords);
      if (result.finalResult && mounted) {
        setState(() { _listening = false; _plan = _actions.plan(_prompt.text); });
      }
    });
  }

  void _makePlan() {
    final text = _prompt.text.trim();
    if (text.isEmpty) return;
    setState(() => _plan = _actions.plan(text));
  }

  Future<void> _confirm() async {
    final plan = _plan;
    if (plan == null || _busy) return;
    setState(() => _busy = true);
    try {
      final data = await _actions.executeConfirmed(plan);
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (_) => AlertDialog(
        title: const Text('SwipeBuy action'),
        content: Text(data['message']?.toString() ?? 'The action was accepted by the backend.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
      ));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The action could not be completed yet. Connect the secure backend action first.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SwipeBuy AI Actions')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF17231F), Color(0xFF121720)]), border: Border.all(color: Colors.white10)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Talk to SwipeBuy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          SizedBox(height: 6),
          Text('Ask SwipeBuy to search, compare, prepare purchases, bookings, job searches and alerts. Sensitive actions always require confirmation.'),
        ]),
      ),
      const SizedBox(height: 16),
      TextField(controller: _prompt, maxLines: 3, decoration: InputDecoration(hintText: 'Example: Find a phone under GHS 4,000 and prepare the best option', filled: true, fillColor: const Color(0xFF121720), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: FilledButton.icon(onPressed: _makePlan, icon: const Icon(Icons.auto_awesome), label: const Text('Create action plan'))),
        const SizedBox(width: 10),
        IconButton.filled(onPressed: _toggleVoice, icon: Icon(_listening ? Icons.stop : Icons.mic), tooltip: 'Voice'),
      ]),
      const SizedBox(height: 8),
      Text(_voiceStatus, style: const TextStyle(color: Colors.white60)),
      const SizedBox(height: 18),
      if (_plan != null) Card(
        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_plan!.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8), Text(_plan!.description, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: FilledButton(onPressed: _busy ? null : _confirm, child: _busy ? const CircularProgressIndicator() : const Text('Confirm & continue'))), const SizedBox(width: 10), OutlinedButton(onPressed: _busy ? null : () => setState(() => _plan = null), child: const Text('Cancel'))]),
        ])),
      ),
      const SizedBox(height: 20),
      OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AskSwipeBuyPage())), icon: const Icon(Icons.search), label: const Text('Open universal search assistant')),
      const SizedBox(height: 10),
      OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MultimodalAiPage())), icon: const Icon(Icons.image_search_outlined), label: const Text('Open Vision AI')),
      const SizedBox(height: 10),
      FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiCommandCenter2Page())), icon: const Icon(Icons.hub_outlined), label: const Text('Open AI 2.0 Command Center')),
    ]),
  );
}
