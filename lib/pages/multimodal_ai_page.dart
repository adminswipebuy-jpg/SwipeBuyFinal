import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/multimodal_ai_service.dart';

class MultimodalAiPage extends StatefulWidget {
  const MultimodalAiPage({super.key});

  @override
  State<MultimodalAiPage> createState() => _MultimodalAiPageState();
}

class _MultimodalAiPageState extends State<MultimodalAiPage> {
  final _prompt = TextEditingController();
  final _picker = ImagePicker();
  final _service = MultimodalAiService();

  XFile? _image;
  bool _busy = false;
  MultimodalAiResult? _result;
  String? _error;

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 2400);
      if (!mounted || picked == null) return;
      setState(() {
        _image = picked;
        _result = null;
        _error = null;
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not access the image picker.');
    }
  }

  Future<void> _analyze() async {
    final image = _image;
    if (image == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await _service.analyzeImage(image: image, prompt: _prompt.text);
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) setState(() => _error = 'Image AI is not connected yet. Securely connect analyzeSwipeBuyImage in Firebase Functions.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('SwipeBuy Vision AI')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(colors: [Color(0xFF17231F), Color(0xFF121720)]),
              border: Border.all(color: Colors.white10),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Show SwipeBuy what you mean', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              SizedBox(height: 8),
              Text('Upload a photo and ask SwipeBuy to identify, explain, compare, or find related content, products, services or places.'),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: _busy ? null : () => _pick(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: const Text('Camera'))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(onPressed: _busy ? null : () => _pick(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const Text('Gallery'))),
          ]),
          const SizedBox(height: 12),
          Container(
            height: 230,
            decoration: BoxDecoration(color: const Color(0xFF121720), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
            clipBehavior: Clip.antiAlias,
            child: _image == null
                ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.image_search_outlined, size: 46), SizedBox(height: 10), Text('Select an image to begin')]))
                : FutureBuilder(
                    future: _image!.readAsBytes(),
                    builder: (_, snap) => snap.hasData
                        ? Image.memory(snap.data!, fit: BoxFit.cover, width: double.infinity)
                        : const Center(child: CircularProgressIndicator()),
                  ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _prompt,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'What should SwipeBuy do with this image?',
              hintText: 'Example: Find similar shoes on SwipeBuy',
              filled: true,
              fillColor: const Color(0xFF121720),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _image == null || _busy ? null : _analyze,
              icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
              label: Text(_busy ? 'Analyzing…' : 'Analyze with SwipeBuy AI'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (_result != null) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Icon(Icons.auto_awesome, color: color), const SizedBox(width: 8), const Text('SwipeBuy says', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))]),
                  const SizedBox(height: 10),
                  Text(_result!.summary, style: const TextStyle(height: 1.45)),
                  if (_result!.tags.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(spacing: 8, runSpacing: 8, children: _result!.tags.map((tag) => Chip(label: Text('#$tag'))).toList()),
                  ],
                  if (_result!.suggestions.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text('Try these next', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    ..._result!.suggestions.map((s) => ListTile(leading: const Icon(Icons.arrow_forward), contentPadding: EdgeInsets.zero, title: Text(s), onTap: () => _prompt.text = s)),
                  ],
                ]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
