import 'package:flutter/material.dart';
import '../services/music_effects_service.dart';

class MusicEffectsLibraryPage extends StatefulWidget {
  final String? selectedMusicId;
  const MusicEffectsLibraryPage({super.key, this.selectedMusicId});
  @override
  State<MusicEffectsLibraryPage> createState() => _MusicEffectsLibraryPageState();
}

class _MusicEffectsLibraryPageState extends State<MusicEffectsLibraryPage> {
  final _service = MusicEffectsService();
  String _query = '';
  String _category = 'Popular';
  String _effect = 'None';
  String _transition = 'Fade';
  String _sticker = 'None';
  String _textAnimation = 'None';
  String _selectedMusicId = 'sb-original';

  final _categories = const ['Popular', 'Afrobeat', 'Highlife', 'Pop', 'Hip-Hop', 'Chill', 'Original'];
  final _effects = const ['None', 'Warm', 'Cool', 'Vibrant', 'Soft Glow', 'Film Grain', 'Mono'];
  final _transitions = const ['Fade', 'Cut', 'Slide', 'Zoom', 'Spin'];
  final _stickers = const ['None', 'Emoji Pack', 'Sale', 'New', 'Location', 'Question'];
  final _textAnimations = const ['None', 'Pop', 'Typewriter', 'Bounce', 'Fade Up', 'Slide'];

  @override
  void initState() {
    super.initState();
    _selectedMusicId = widget.selectedMusicId ?? 'sb-original';
  }

  List<MusicTrack> get _tracks {
    final q = _query.trim().toLowerCase();
    return MusicEffectsService.tracks.where((t) {
      final categoryMatch = _category == 'Popular' ? t.popular : t.category == _category;
      final queryMatch = q.isEmpty || t.title.toLowerCase().contains(q) || t.creator.toLowerCase().contains(q);
      return categoryMatch && queryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selected = MusicEffectsService.tracks.firstWhere((t) => t.id == _selectedMusicId, orElse: () => MusicEffectsService.tracks.last);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music & Effects', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [TextButton(onPressed: () => Navigator.pop(context, {'musicId': _selectedMusicId, 'music': selected.title, 'effect': _effect, 'transition': _transition, 'sticker': _sticker, 'textAnimation': _textAnimation}), child: const Text('Done'))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          TextField(onChanged: (v) => setState(() => _query = v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search sounds, creators or moods', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))),
          const SizedBox(height: 12),
          SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _categories.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => ChoiceChip(label: Text(_categories[i]), selected: _category == _categories[i], onSelected: (_) => setState(() => _category = _categories[i])))),
          const SizedBox(height: 18),
          const Text('Choose a sound', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ..._tracks.map((track) => Card(
                color: const Color(0xFF101720),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Icon(track.original ? Icons.mic : Icons.music_note)),
                  title: Text(track.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${track.creator} • ${track.durationSeconds == 0 ? 'Live recording' : '${track.durationSeconds}s'}'),
                  trailing: Radio<String>(value: track.id, groupValue: _selectedMusicId, onChanged: (v) => setState(() => _selectedMusicId = v!)),
                  onTap: () => setState(() => _selectedMusicId = track.id),
                ),
              )),
          const SizedBox(height: 18),
          _section('Audio mix', [
            const ListTile(leading: Icon(Icons.record_voice_over), title: Text('Original sound'), subtitle: Text('Keep your recorded voice or camera audio')),
            Slider(value: 0.85, onChanged: (_) {}, label: '85%'),
            const ListTile(leading: Icon(Icons.music_note), title: Text('Added music'), subtitle: Text('Mix the selected track without overpowering speech')),
            Slider(value: 0.55, onChanged: (_) {}, label: '55%'),
          ]),
          _section('Effects', [_menu('Visual effect', _effects, _effect, (v) => setState(() => _effect = v)), _menu('Transition', _transitions, _transition, (v) => setState(() => _transition = v))]),
          _section('Creative layers', [_menu('Stickers', _stickers, _sticker, (v) => setState(() => _sticker = v)), _menu('Animated text', _textAnimations, _textAnimation, (v) => setState(() => _textAnimation = v))]),
          _section('Creator safety', [
            const ListTile(leading: Icon(Icons.copyright), title: Text('Audio rights reminder'), subtitle: Text('Use sounds you own or are licensed to use. Platform availability can vary by country.')),
            SwitchListTile(contentPadding: EdgeInsets.zero, value: true, onChanged: (_) {}, title: const Text('Keep captions in safe area', style: TextStyle(fontWeight: FontWeight.w800))),
          ]),
        ],
      ),
    );
  }

  Widget _menu(String label, List<String> items, String value, ValueChanged<String> onChanged) => Padding(padding: const EdgeInsets.only(bottom: 12), child: DropdownButtonFormField<String>(value: value, decoration: InputDecoration(labelText: label, filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) { if (v != null) onChanged(v); }));

  Widget _section(String title, List<Widget> children) => Card(color: const Color(0xFF101720), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 10), ...children])));
}
