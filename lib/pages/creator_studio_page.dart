import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/creator_publish_service.dart';
import '../services/media_service.dart';
import 'create_content_page.dart';
import 'stories_page.dart';
import 'live_hub_page.dart';

class CreatorStudioPage extends StatefulWidget {
  const CreatorStudioPage({super.key});
  @override
  State<CreatorStudioPage> createState() => _CreatorStudioPageState();
}

class _CreatorStudioPageState extends State<CreatorStudioPage> {
  final picker = ImagePicker();
  final publish = CreatorPublishService();
  final caption = TextEditingController();
  String category = 'Lifestyle';
  String? storyUrl;
  String storyType = 'image';
  bool busy = false;

  Future<void> pickStory() async {
    final x = await picker.pickMedia();
    if (x == null) return;
    setState(() => busy = true);
    try {
      final file = File(x.path);
      final isVideo = x.mimeType?.startsWith('video/') == true || x.name.toLowerCase().endsWith('.mp4');
      storyUrl = isVideo ? await MediaService.uploadVideo(file) : await MediaService.uploadImage(file);
      storyType = isVideo ? 'video' : 'image';
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Story upload failed: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> publishStory() async {
    if (storyUrl == null) return;
    setState(() => busy = true);
    try {
      await publish.createStory(mediaUrl: storyUrl!, mediaType: storyType, caption: caption.text, category: category);
      if (mounted) {
        caption.clear();
        setState(() => storyUrl = null);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Story published for 24 hours.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not publish story: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> startLive() async {
    final title = TextEditingController();
    String liveCategory = category;
    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Start a SwipeBuy LIVE'),
        content: StatefulBuilder(builder: (_, setStateDialog) => Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Live title')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(initialValue: liveCategory, items: const ['Sports','News','Forex','Crypto','Investment','Real Estate','Jobs','Education','Fitness','Lifestyle','Entertainment','Shopping'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setStateDialog(() => liveCategory = v!)),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            if (title.text.trim().isEmpty) return;
            await publish.createLiveSession(title: title.text.trim(), category: liveCategory);
            if (dialogContext.mounted) Navigator.pop(dialogContext, true);
          }, child: const Text('Go LIVE')),
        ],
      ),
    );
    if (result == true && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('LIVE session created. Connect your broadcast stream to the session.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Creator Studio'), actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveHubPage())), icon: const Icon(Icons.live_tv_outlined))]),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('Create. Connect. Grow.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('Everything a SwipeBuy creator needs to publish content and build an audience.', style: TextStyle(color: Colors.white60)),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(child: _StudioCard(icon: Icons.video_camera_back, title: 'Post', subtitle: 'Photo or video', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateContentPage())))),
        const SizedBox(width: 12),
        Expanded(child: _StudioCard(icon: Icons.auto_awesome_motion, title: 'Stories', subtitle: '24-hour posts', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoriesPage())))),
      ]),
      const SizedBox(height: 12),
      _StudioCard(icon: Icons.wifi_tethering, title: 'Go LIVE', subtitle: 'Talk to your audience in real time', onTap: startLive),
      const SizedBox(height: 20),
      Card(color: const Color(0xFF111720), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Quick Story', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6), const Text('Share a behind-the-scenes moment, deal, tip or update.', style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(initialValue: category, items: const ['Sports','News','Forex','Crypto','Investment','Real Estate','Jobs','Education','Fitness','Lifestyle','Food','Hotels','Beauty','Entertainment','Travel','Services'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => category = v!)),
        const SizedBox(height: 12),
        TextField(controller: caption, maxLines: 3, decoration: const InputDecoration(labelText: 'Story caption', filled: true)),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: busy ? null : pickStory, icon: const Icon(Icons.perm_media_outlined), label: Text(storyUrl == null ? 'Choose photo or video' : 'Media attached')),
        const SizedBox(height: 12),
        SizedBox(height: 50, child: FilledButton(onPressed: busy || storyUrl == null ? null : publishStory, child: busy ? const CircularProgressIndicator() : const Text('Publish Story'))),
      ]))),
    ]),
  );
}

class _StudioCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  const _StudioCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Card(color: const Color(0xFF111720), child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: const Color(0xFF38D9A9), size: 30), const SizedBox(height: 18), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white60))]))));
}
