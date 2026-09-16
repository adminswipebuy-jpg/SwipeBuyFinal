import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/creator_content_service.dart';
import '../services/media_service.dart';

class CreateContentPage extends StatefulWidget {
  const CreateContentPage({super.key});
  @override
  State<CreateContentPage> createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  final text = TextEditingController();
  final picker = ImagePicker();
  String category = 'Lifestyle';
  String? mediaUrl;
  String mediaType = 'text';
  bool busy = false;
  final service = CreatorContentService();

  Future<void> pick() async {
    final x = await picker.pickMedia();
    if (x == null) return;
    setState(() => busy = true);
    try {
      final file = File(x.path);
      final isVideo = x.mimeType?.startsWith('video/') == true || x.name.toLowerCase().endsWith('.mp4');
      mediaUrl = isVideo ? await MediaService.uploadVideo(file) : await MediaService.uploadImage(file);
      mediaType = isVideo ? 'video' : 'image';
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> publish() async {
    if (text.text.trim().isEmpty && mediaUrl == null) return;
    setState(() => busy = true);
    try {
      await service.createPost(text: text.text, category: category, mediaUrl: mediaUrl, mediaType: mediaType);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not publish: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create on SwipeBuy')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Share something people can discover.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: category,
          decoration: const InputDecoration(labelText: 'Category', filled: true),
          items: const ['Sports','News','Forex','Crypto','Investment','Real Estate','Jobs','Education','Fitness','Lifestyle','Food','Hotels','Beauty','Entertainment','Travel','Services']
              .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => category = v!),
        ),
        const SizedBox(height: 14),
        TextField(controller: text, maxLines: 6, decoration: const InputDecoration(labelText: 'Caption', hintText: 'Tell the SwipeBuy community something useful or interesting...', filled: true)),
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: busy ? null : pick, icon: const Icon(Icons.perm_media_outlined), label: Text(mediaUrl == null ? 'Add photo or video' : 'Media attached')),
        if (mediaUrl != null) Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text('Ready to publish: $mediaType', style: const TextStyle(color: Colors.white60)),
        ),
        const SizedBox(height: 20),
        SizedBox(height: 54, child: FilledButton(onPressed: busy ? null : publish, child: busy ? const CircularProgressIndicator() : const Text('Publish', style: TextStyle(fontWeight: FontWeight.w900)))),
      ],
    ),
  );
}
