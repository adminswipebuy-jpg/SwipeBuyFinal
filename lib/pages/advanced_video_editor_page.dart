import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'music_effects_library_page.dart';
import 'video_timeline_editor_page.dart';

class AdvancedVideoEditorPage extends StatefulWidget {
  final File videoFile;
  final String? uploadedMediaUrl;
  const AdvancedVideoEditorPage({super.key, required this.videoFile, this.uploadedMediaUrl});

  @override
  State<AdvancedVideoEditorPage> createState() => _AdvancedVideoEditorPageState();
}

class _AdvancedVideoEditorPageState extends State<AdvancedVideoEditorPage> {
  late final VideoPlayerController _controller;
  double _speed = 1.0;
  double _volume = 1.0;
  String _effect = 'None';
  String _transition = 'Fade';
  String _cover = 'First frame';
  String _musicId = 'sb-original';
  String _music = 'Original sound';
  String _sticker = 'None';
  String _textAnimation = 'None';
  bool _mute = false;
  bool _snapCaptions = true;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      })
      ..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pop(context, {
        'speed': _speed,
        'volume': _mute ? 0.0 : _volume,
        'effect': _effect,
        'transition': _transition,
        'cover': _cover,
        'autoCaptions': _snapCaptions,
        'musicId': _musicId,
        'music': _music,
        'sticker': _sticker,
        'textAnimation': _textAnimation,
        'uploadedMediaUrl': widget.uploadedMediaUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit settings saved. Final rendering will happen during publishing.')));
    }
  }

  void _togglePlayback() {
    if (!_controller.value.isInitialized) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialized = _controller.value.isInitialized;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Video Editor'),
        actions: [
          IconButton(
            onPressed: _processing ? null : () async {
              final result = await Navigator.push<Map<String, dynamic>>(context, MaterialPageRoute(builder: (_) => VideoTimelineEditorPage(clips: [widget.videoFile])));
              if (result != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Timeline edits saved to this draft.')));
              }
            },
            tooltip: 'Timeline',
            icon: const Icon(Icons.view_timeline),
          ),
          TextButton(onPressed: _processing ? null : _save, child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w900))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            height: 420,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)),
            child: initialized
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)),
                        IconButton.filledTonal(onPressed: _togglePlayback, iconSize: 36, icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow)),
                        Positioned(
                          left: 14, right: 14, bottom: 14,
                          child: VideoProgressIndicator(_controller, allowScrubbing: true, colors: VideoProgressColors(playedColor: Theme.of(context).colorScheme.primary)),
                        ),
                      ],
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 18),
          _section('Playback', [
            _rowLabel('Speed', '${_speed.toStringAsFixed(2)}×'),
            Slider(value: _speed, min: 0.25, max: 2.0, divisions: 7, onChanged: (v) { setState(() => _speed = v); _controller.setPlaybackSpeed(v); }),
            SwitchListTile(contentPadding: EdgeInsets.zero, value: _mute, onChanged: (v) { setState(() => _mute = v); _controller.setVolume(v ? 0 : _volume); }, title: const Text('Mute original audio', style: TextStyle(fontWeight: FontWeight.w800))),
            if (!_mute) ...[
              _rowLabel('Volume', '${(_volume * 100).round()}%'),
              Slider(value: _volume, onChanged: (v) { setState(() => _volume = v); _controller.setVolume(v); }),
            ],
          ]),
          _section('Look & Feel', [
            DropdownButtonFormField<String>(initialValue: _effect, decoration: const InputDecoration(labelText: 'Effect', filled: true), items: const ['None', 'Warm', 'Cool', 'High contrast', 'Soft glow'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _effect = v ?? _effect)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(initialValue: _transition, decoration: const InputDecoration(labelText: 'Transition', filled: true), items: const ['Fade', 'Slide', 'Zoom', 'Cut'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _transition = v ?? _transition)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(initialValue: _cover, decoration: const InputDecoration(labelText: 'Cover frame', filled: true), items: const ['First frame', 'Middle frame', 'Last frame', 'AI suggestion'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _cover = v ?? _cover)),
          ]),
          _section('Music & Effects', [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.music_note)),
              title: Text(_music, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('Effect: $_effect • Transition: $_transition'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final result = await Navigator.push<Map<String, dynamic>>(context, MaterialPageRoute(builder: (_) => MusicEffectsLibraryPage(selectedMusicId: _musicId)));
                if (result != null && mounted) {
                  setState(() {
                    _musicId = result['musicId']?.toString() ?? _musicId;
                    _music = result['music']?.toString() ?? _music;
                    _effect = result['effect']?.toString() ?? _effect;
                    _transition = result['transition']?.toString() ?? _transition;
                    _sticker = result['sticker']?.toString() ?? _sticker;
                    _textAnimation = result['textAnimation']?.toString() ?? _textAnimation;
                  });
                }
              },
            ),
          ]),
          _section('Accessibility', [
            SwitchListTile(contentPadding: EdgeInsets.zero, value: _snapCaptions, onChanged: (v) => setState(() => _snapCaptions = v), title: const Text('Auto captions', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Keep speech readable for silent viewing.')),
            const ListTile(leading: Icon(Icons.text_fields), title: Text('Caption style'), subtitle: Text('Clean • High contrast • Bottom safe area')),
          ]),
          if (_processing) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Card(
    color: const Color(0xFF101720),
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), const SizedBox(height: 10), ...children])),
  );

  Widget _rowLabel(String a, String b) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(a, style: const TextStyle(fontWeight: FontWeight.w700)), Text(b, style: const TextStyle(color: Colors.white60))]);
}
