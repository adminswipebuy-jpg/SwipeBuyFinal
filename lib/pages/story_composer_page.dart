import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/creator_publish_service.dart';
import '../services/media_service.dart';

class StoryComposerPage extends StatefulWidget {
  const StoryComposerPage({super.key});

  @override
  State<StoryComposerPage> createState() => _StoryComposerPageState();
}

class _StoryComposerPageState extends State<StoryComposerPage> {
  final picker = ImagePicker();
  final caption = TextEditingController();
  final publishService = CreatorPublishService();
  XFile? selected;
  String category = 'General';
  String privacy = 'public';
  bool busy = false;

  final categories = const [
    'General', 'Business', 'Fashion', 'Food', 'Travel', 'Sports', 'Education', 'Entertainment', 'Lifestyle'
  ];

  @override
  void dispose() {
    caption.dispose();
    super.dispose();
  }

  Future<void> pick(ImageSource source) async {
    final file = await picker.pickImage(source: source, imageQuality: 88, maxWidth: 1600);
    if (file != null && mounted) setState(() => selected = file);
  }

  Future<void> publish() async {
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose a photo first.')));
      return;
    }
    setState(() => busy = true);
    try {
      final url = await MediaService.uploadImage(File(selected!.path));
      await publishService.createStory(
        mediaUrl: url,
        mediaType: 'image',
        caption: caption.text.trim(),
        category: category,
        privacy: privacy,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Story published for 24 hours.')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not publish story. Please try again.')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Story')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AspectRatio(
            aspectRatio: 9 / 14,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFF111720),
              ),
              clipBehavior: Clip.antiAlias,
              child: selected == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_stories_outlined, size: 64),
                        const SizedBox(height: 14),
                        const Text('Create a story', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        const Text('Share a moment for the next 24 hours.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 10,
                          children: [
                            OutlinedButton.icon(onPressed: busy ? null : () => pick(ImageSource.camera), icon: const Icon(Icons.photo_camera_outlined), label: const Text('Camera')),
                            OutlinedButton.icon(onPressed: busy ? null : () => pick(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const Text('Gallery')),
                          ],
                        ),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(selected!.path), fit: BoxFit.cover),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: IconButton.filledTonal(onPressed: () => setState(() => selected = null), icon: const Icon(Icons.close)),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: caption,
            maxLength: 180,
            decoration: InputDecoration(
              labelText: 'Caption',
              hintText: 'What are you sharing?',
              filled: true,
              fillColor: const Color(0xFF111720),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: category,
            decoration: InputDecoration(labelText: 'Category', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
            items: categories.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: busy ? null : (v) => setState(() => category = v ?? 'General'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: privacy,
            decoration: InputDecoration(labelText: 'Who can see it?', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
            items: const [
              DropdownMenuItem(value: 'public', child: Text('Everyone')),
              DropdownMenuItem(value: 'followers', child: Text('Followers')),
              DropdownMenuItem(value: 'private', child: Text('Only me')),
            ],
            onChanged: busy ? null : (v) => setState(() => privacy = v ?? 'public'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: busy ? null : publish,
              icon: busy ? const SizedBox(width: 19, height: 19, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.publish_outlined),
              label: Text(busy ? 'Publishing…' : 'Publish Story'),
            ),
          ),
        ],
      ),
    );
  }
}
