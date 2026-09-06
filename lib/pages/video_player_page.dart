import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/content_feed_service.dart';
import '../services/content_analytics_service.dart';

class VideoPlayerPage extends StatefulWidget {
  final ContentItem item;
  const VideoPlayerPage({super.key, required this.item});
  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? controller;
  bool failed = false;
  final analytics = ContentAnalyticsService();

  @override
  void initState() {
    super.initState();
    final url = widget.item.imageUrl;
    if (widget.item.contentType == 'video' && url != null && url.isNotEmpty) {
      controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          controller!.play();
          controller!.setLooping(true);
          analytics.record(widget.item.id, 'video_start');
        }).catchError((_) { if (mounted) setState(() => failed = true); });
    }
  }

  @override
  void dispose() { controller?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (controller == null || failed) return const Center(child: Icon(Icons.videocam_off_outlined, size: 54));
    if (!controller!.value.isInitialized) return const Center(child: CircularProgressIndicator());
    return GestureDetector(
      onTap: () {
        if (controller!.value.isPlaying) {
          controller!.pause();
          analytics.record(widget.item.id, 'video_pause');
        } else {
          controller!.play();
          analytics.record(widget.item.id, 'video_resume');
        }
        setState(() {});
      },
      child: FittedBox(fit: BoxFit.cover, child: SizedBox(width: controller!.value.size.width, height: controller!.value.size.height, child: VideoPlayer(controller!))),
    );
  }
}
