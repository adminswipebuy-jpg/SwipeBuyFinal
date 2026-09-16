import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../services/content_creation_studio_service.dart';
import '../services/media_service.dart';
import 'advanced_video_editor_page.dart';

class ContentCreationStudioPage extends StatefulWidget {
  const ContentCreationStudioPage({super.key});
  @override
  State<ContentCreationStudioPage> createState() => _ContentCreationStudioPageState();
}

class _ContentCreationStudioPageState extends State<ContentCreationStudioPage> {
  final _picker = ImagePicker();
  final _caption = TextEditingController();
  final _service = ContentCreationStudioService();
  VideoPlayerController? _controller;
  File? _videoFile;
  String? _mediaUrl;
  String? _coverUrl;
  String _category = 'Lifestyle';
  String? _music = 'Original sound';
  bool _autoCaptions = true;
  bool _busy = false;
  RangeValues _trim = const RangeValues(0, 60);
  final List<Map<String, dynamic>> _overlays = [];

  Future<void> _pickVideo(ImageSource source) async {
    final picked = await _picker.pickVideo(source: source, maxDuration: const Duration(minutes: 5));
    if (picked == null) return;
    setState(() => _busy = true);
    try {
      await _controller?.dispose();
      final file = File(picked.path);
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      final max = controller.value.duration.inSeconds.clamp(1, 300).toDouble();
      setState(() {
        _videoFile = file;
        _controller = controller;
        _trim = RangeValues(0, max);
      });
      await controller.play();
      controller.setLooping(true);
      _mediaUrl = await MediaService.uploadVideo(file);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video setup failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addTextOverlay() async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add text overlay'),
        content: TextField(controller: controller, maxLines: 2, decoration: const InputDecoration(hintText: 'Text to show on the video')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Add'))],
      ),
    );
    if (value == null || value.isEmpty) return;
    setState(() => _overlays.add({'text': value, 'position': 'center', 'style': 'bold'}));
  }

  Future<void> _saveDraft() async {
    if (_mediaUrl == null) return;
    setState(() => _busy = true);
    try {
      await _service.saveDraft(category: _category, caption: _caption.text, mediaUrl: _mediaUrl!, mediaType: 'video', coverUrl: _coverUrl, music: _music, trimStart: _trim.start, trimEnd: _trim.end, autoCaptions: _autoCaptions, overlays: _overlays);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save draft: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _publish() async {
    if (_mediaUrl == null || _caption.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a video and caption first.')));
      return;
    }
    setState(() => _busy = true);
    try {
      await _service.publishVideo(category: _category, caption: _caption.text, mediaUrl: _mediaUrl!, coverUrl: _coverUrl, music: _music, trimStart: _trim.start, trimEnd: _trim.end, autoCaptions: _autoCaptions, overlays: _overlays);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Publish failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final hasVideo = controller?.value.isInitialized == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creation Studio', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [TextButton(onPressed: _busy ? null : _saveDraft, child: const Text('Save draft'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 360,
            decoration: BoxDecoration(color: const Color(0xFF0B1017), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
            clipBehavior: Clip.antiAlias,
            child: hasVideo
                ? Stack(alignment: Alignment.center, children: [AspectRatio(aspectRatio: controller!.value.aspectRatio, child: VideoPlayer(controller)), Positioned(bottom: 12, left: 12, right: 12, child: Row(children: [Expanded(child: VideoProgressIndicator(controller, allowScrubbing: true)), IconButton(onPressed: () => setState(() => controller.value.isPlaying ? controller.pause() : controller.play()), icon: Icon(controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 40))]))])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.videocam_outlined, size: 66, color: Color(0xFF38D9A9)), const SizedBox(height: 12), const Text('Create a vertical video', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 8), const Text('Record with your camera or choose a video from your gallery.', style: TextStyle(color: Colors.white60), textAlign: TextAlign.center), const SizedBox(height: 20), Wrap(alignment: WrapAlignment.center, spacing: 10, children: [FilledButton.icon(onPressed: _busy ? null : () => _pickVideo(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('Record')), OutlinedButton.icon(onPressed: _busy ? null : () => _pickVideo(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const Text('Gallery'))])]),
          ),
          const SizedBox(height: 18),
          if (hasVideo) ...[
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : () async {
                  final result = await Navigator.push<Map<String, dynamic>>(context, MaterialPageRoute(builder: (_) => AdvancedVideoEditorPage(videoFile: _videoFile!, uploadedMediaUrl: _mediaUrl)));
                  if (result != null && mounted) {
                    setState(() {
                      _music = result['music']?.toString() ?? _music;
                      _autoCaptions = result['autoCaptions'] == true ? true : _autoCaptions;
                      _overlays.add({'effect': result['effect'], 'transition': result['transition'], 'cover': result['cover'], 'speed': result['speed'], 'volume': result['volume']});
                    });
                  }
                },
                icon: const Icon(Icons.tune),
                label: const Text('Open advanced editor'),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text('Trim ${_trim.start.toStringAsFixed(0)}s – ${_trim.end.toStringAsFixed(0)}s', style: const TextStyle(fontWeight: FontWeight.w800)),
          RangeSlider(values: _trim, min: 0, max: _trim.end < 60 ? 60 : _trim.end, onChanged: hasVideo ? (v) => setState(() => _trim = v) : null),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(initialValue: _category, decoration: const InputDecoration(labelText: 'Category', filled: true), items: const ['Sports','News','Forex','Crypto','Investment','Real Estate','Jobs','Education','Fitness','Lifestyle','Food','Hotels','Beauty','Entertainment','Travel','Services'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _category = v ?? _category)),
          const SizedBox(height: 12),
          TextField(controller: _caption, maxLines: 4, decoration: const InputDecoration(labelText: 'Caption', hintText: 'Write something people will want to watch, learn, buy or share.', filled: true)),
          const SizedBox(height: 12),
          Card(color: const Color(0xFF101720), child: Column(children: [SwitchListTile(value: _autoCaptions, onChanged: (v) => setState(() => _autoCaptions = v), title: const Text('Auto captions', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Prepare captions for accessibility and silent viewing')), ListTile(leading: const Icon(Icons.music_note), title: const Text('Soundtrack'), subtitle: Text(_music ?? 'Choose a sound'), trailing: const Icon(Icons.chevron_right), onTap: () async { final choice = await showDialog<String>(context: context, builder: (_) => SimpleDialog(title: const Text('Choose sound'), children: ['Original sound','Trending Afrobeat','Calm instrumental','Business beat'].map((x) => SimpleDialogOption(onPressed: () => Navigator.pop(context, x), child: Text(x))).toList())); if (choice != null) setState(() => _music = choice); }), ListTile(leading: const Icon(Icons.text_fields), title: const Text('Text overlays'), subtitle: Text('${_overlays.length} overlay${_overlays.length == 1 ? '' : 's'}'), trailing: const Icon(Icons.add), onTap: _addTextOverlay)])),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: OutlinedButton.icon(onPressed: _busy ? null : _saveDraft, icon: const Icon(Icons.bookmark_border), label: const Text('Draft'))), const SizedBox(width: 10), Expanded(child: FilledButton.icon(onPressed: _busy ? null : _publish, icon: const Icon(Icons.publish), label: const Text('Publish')))]),
          if (_busy) const Padding(padding: EdgeInsets.only(top: 14), child: LinearProgressIndicator()),
        ],
      ),
    );
  }
}
