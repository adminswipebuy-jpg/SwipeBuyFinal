import 'package:flutter/material.dart';
import '../services/media_transcoding_service.dart';

class MediaTranscodingPage extends StatefulWidget {
  const MediaTranscodingPage({super.key});
  @override State<MediaTranscodingPage> createState() => _MediaTranscodingPageState();
}

class _MediaTranscodingPageState extends State<MediaTranscodingPage> {
  final service = MediaTranscodingService();
  final mediaId = TextEditingController();
  final issue = TextEditingController();
  bool loading = false;

  Future<void> _request(Future<void> Function() task, String success) async {
    if (loading) return;
    setState(() => loading = true);
    try {
      await task();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request could not be created')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() { mediaId.dispose(); issue.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Media Processing 2.0')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.movie_filter_outlined, size: 40),
        const SizedBox(height: 10),
        const Text('SwipeBuy Media Processing', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Professional transcoding and playback preparation for short video, LIVE replays and creator media.'),
        const SizedBox(height: 14),
        const Wrap(spacing: 8, runSpacing: 8, children: [Chip(label: Text('HLS/DASH')), Chip(label: Text('ABR ladder')), Chip(label: Text('Thumbnails')), Chip(label: Text('Transcoding'))]),
      ]))),
      const SizedBox(height: 12),
      TextField(controller: mediaId, decoration: const InputDecoration(labelText: 'Media ID', hintText: 'e.g. media_123', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: issue, maxLines: 3, decoration: const InputDecoration(labelText: 'Playback issue (optional)', border: OutlineInputBorder())),
      const SizedBox(height: 14),
      FilledButton.icon(onPressed: loading ? null : () => _request(() => service.requestTranscode(mediaId: mediaId.text), 'Adaptive transcode request created'), icon: const Icon(Icons.transform_outlined), label: const Text('Prepare Adaptive Video')),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: loading ? null : () => _request(() => service.requestThumbnail(mediaId: mediaId.text), 'Thumbnail request created'), icon: const Icon(Icons.image_outlined), label: const Text('Generate Thumbnails')),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: loading ? null : () => _request(() => service.requestPlaybackReview(mediaId: mediaId.text, issue: issue.text.isEmpty ? 'Playback issue reported by user.' : issue.text), 'Playback review created'), icon: const Icon(Icons.play_circle_outline), label: const Text('Report Playback Problem')),
      const SizedBox(height: 14),
      const Card(child: ListTile(leading: Icon(Icons.admin_panel_settings_outlined), title: Text('Production architecture'), subtitle: Text('A trusted media pipeline should create multiple renditions, manifests, thumbnails and CDN-ready assets. The client only requests processing and reads verified status.'))),
    ]),
  );
}
