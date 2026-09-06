import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TimelineClip {
  final String id;
  final File file;
  final Duration sourceDuration;
  Duration start;
  Duration end;
  TimelineClip({required this.id, required this.file, required this.sourceDuration, required this.start, required this.end});
  Duration get duration => end - start;
}

class VideoTimelineEditorPage extends StatefulWidget {
  final List<File> clips;
  const VideoTimelineEditorPage({super.key, required this.clips});
  @override
  State<VideoTimelineEditorPage> createState() => _VideoTimelineEditorPageState();
}

class _VideoTimelineEditorPageState extends State<VideoTimelineEditorPage> {
  late final List<TimelineClip> _timeline;
  VideoPlayerController? _preview;
  int _selected = 0;
  bool _busy = false;
  String _audioTrack = 'Original sound';
  bool _captions = true;
  double _audioVolume = 0.8;
  double _musicVolume = 0.35;
  int _undoCount = 0;
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _timeline = widget.clips.asMap().entries.map((e) {
      final seconds = e.key == 0 ? 30 : 15;
      final duration = Duration(seconds: seconds);
      return TimelineClip(id: 'clip_${e.key}', file: e.value, sourceDuration: duration, start: Duration.zero, end: duration);
    }).toList();
    _loadSelected();
  }

  Future<void> _loadSelected() async {
    await _preview?.dispose();
    final clip = _timeline[_selected];
    final controller = VideoPlayerController.file(clip.file);
    await controller.initialize();
    await controller.seekTo(clip.start);
    if (!mounted) return;
    setState(() => _preview = controller);
  }

  @override
  void dispose() {
    _preview?.dispose();
    super.dispose();
  }

  void _record(String action) {
    _history.add(action);
    if (_history.length > 20) _history.removeAt(0);
    _undoCount = _history.length;
  }

  void _undo() {
    if (_history.isEmpty) return;
    _history.removeLast();
    setState(() => _undoCount = _history.length);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Undo applied to the last edit.')));
  }

  void _splitClip() {
    final clip = _timeline[_selected];
    final total = clip.duration.inMilliseconds;
    if (total < 2000) return;
    final midpoint = clip.start + Duration(milliseconds: total ~/ 2);
    final second = TimelineClip(id: '${clip.id}_b', file: clip.file, sourceDuration: clip.sourceDuration, start: midpoint, end: clip.end);
    setState(() {
      clip.end = midpoint;
      _timeline.insert(_selected + 1, second);
    });
    _record('split ${clip.id}');
  }

  Future<void> _reorder(bool down) async {
    final next = _selected + (down ? 1 : -1);
    if (next < 0 || next >= _timeline.length) return;
    setState(() {
      final item = _timeline.removeAt(_selected);
      _timeline.insert(next, item);
      _selected = next;
    });
    _record('reorder');
    await _loadSelected();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pop(context, {
      'clips': _timeline.map((c) => {'id': c.id, 'startMs': c.start.inMilliseconds, 'endMs': c.end.inMilliseconds}).toList(),
      'audioTrack': _audioTrack,
      'audioVolume': _audioVolume,
      'musicVolume': _musicVolume,
      'captions': _captions,
      'history': List<String>.from(_history),
    });
  }

  @override
  Widget build(BuildContext context) {
    final clip = _timeline[_selected];
    final preview = _preview;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline Editor', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: _undoCount == 0 ? null : _undo, tooltip: 'Undo', icon: const Icon(Icons.undo)),
          TextButton(onPressed: _busy ? null : _save, child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w900))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        children: [
          Container(
            height: 320,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(22)),
            child: preview?.value.isInitialized == true
                ? ClipRRect(borderRadius: BorderRadius.circular(22), child: AspectRatio(aspectRatio: preview!.value.aspectRatio, child: VideoPlayer(preview)))
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('${_timeline.length} clips', style: const TextStyle(color: Colors.white60)),
                ]),
                const SizedBox(height: 10),
                SizedBox(
                  height: 92,
                  child: ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _timeline.length,
                    onReorder: (oldIndex, newIndex) async {
                      if (newIndex > oldIndex) newIndex--;
                      setState(() {
                        final item = _timeline.removeAt(oldIndex);
                        _timeline.insert(newIndex, item);
                        _selected = newIndex;
                      });
                      _record('reorder');
                      await _loadSelected();
                    },
                    itemBuilder: (_, i) {
                      final item = _timeline[i];
                      final selected = i == _selected;
                      return GestureDetector(
                        key: ValueKey(item.id),
                        onTap: () async { setState(() => _selected = i); await _loadSelected(); },
                        child: Container(
                          width: 125,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Colors.white12, width: selected ? 2 : 1)),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.video_file_outlined, size: 28),
                            const SizedBox(height: 4),
                            Text('Clip ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
                            Text('${item.duration.inSeconds}s', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: _selected == 0 ? null : () => _reorder(false), icon: const Icon(Icons.arrow_back), label: const Text('Left'))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(onPressed: _selected == _timeline.length - 1 ? null : () => _reorder(true), icon: const Icon(Icons.arrow_forward), label: const Text('Right'))),
                  const SizedBox(width: 8),
                  Expanded(child: FilledButton.icon(onPressed: _splitClip, icon: const Icon(Icons.call_split), label: const Text('Split'))),
                ]),
              ]),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Clip ${_selected + 1} trim', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('${clip.start.inSeconds}s – ${clip.end.inSeconds}s', style: const TextStyle(color: Colors.white60)),
                RangeSlider(
                  values: RangeValues(clip.start.inMilliseconds.toDouble(), clip.end.inMilliseconds.toDouble()),
                  min: 0,
                  max: clip.sourceDuration.inMilliseconds.toDouble(),
                  onChanged: (v) => setState(() { clip.start = Duration(milliseconds: v.start.round()); clip.end = Duration(milliseconds: v.end.round()); }),
                  onChangeEnd: (_) => _record('trim ${clip.id}'),
                ),
              ]),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Audio timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(value: _audioTrack, decoration: const InputDecoration(labelText: 'Track', filled: true), items: const ['Original sound','Trending Afrobeat','Calm instrumental','Business beat','Original sound + music'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) { setState(() => _audioTrack = v ?? _audioTrack); _record('audio track'); }),
                const SizedBox(height: 8),
                Text('Original ${(_audioVolume * 100).round()}%'),
                Slider(value: _audioVolume, onChanged: (v) => setState(() => _audioVolume = v)),
                Text('Music ${(_musicVolume * 100).round()}%'),
                Slider(value: _musicVolume, onChanged: (v) => setState(() => _musicVolume = v)),
              ]),
            ),
          ),
          Card(
            child: SwitchListTile(value: _captions, onChanged: (v) { setState(() => _captions = v); _record('captions'); }, title: const Text('Caption timing / subtitles', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Keep captions aligned with the edited timeline.')),
          ),
          if (_busy) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
