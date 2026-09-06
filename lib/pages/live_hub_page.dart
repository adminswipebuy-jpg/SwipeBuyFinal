import 'package:flutter/material.dart';
import '../services/creator_publish_service.dart';

class LiveHubPage extends StatelessWidget {
  const LiveHubPage({super.key});
  @override
  Widget build(BuildContext context) {
    final service = CreatorPublishService();
    return Scaffold(
      appBar: AppBar(title: const Text('SwipeBuy LIVE')),
      body: StreamBuilder(
        stream: service.activeLives(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No live creators right now.'));
          return ListView.separated(
            padding: const EdgeInsets.all(14), itemCount: docs.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) { final d = docs[i].data(); return Card(color: const Color(0xFF111720), child: ListTile(leading: Container(width: 54, height: 54, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Color(0xFFFF7A18), Color(0xFF10B981)])), child: const Icon(Icons.wifi_tethering, color: Colors.white)), title: Text(d['title']?.toString() ?? 'SwipeBuy LIVE', style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('${d['creator'] ?? 'Creator'} • ${d['category'] ?? 'Lifestyle'}\n${d['viewerCount'] ?? 0} viewers'), isThreeLine: true, trailing: FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LiveRoomPage(title: d['title']?.toString() ?? 'SwipeBuy LIVE'))), child: const Text('Watch')))); },
          );
        },
      ),
    );
  }
}

class LiveRoomPage extends StatefulWidget {
  final String title;
  const LiveRoomPage({super.key, required this.title});
  @override State<LiveRoomPage> createState() => _LiveRoomPageState();
}
class _LiveRoomPageState extends State<LiveRoomPage> {
  final comment = TextEditingController();
  final comments = <String>[];
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.black), body: Stack(children: [
    const Positioned.fill(child: ColoredBox(color: Color(0xFF080A0E), child: Center(child: Icon(Icons.live_tv, size: 90, color: Colors.white24)))),
    Positioned(left: 16, top: 18, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)), child: const Text('LIVE', style: TextStyle(fontWeight: FontWeight.w900)))),
    Positioned(right: 16, top: 18, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)), child: const Text('0 watching'))),
    Positioned(left: 14, right: 14, bottom: 14, child: Column(children: [for (final c in comments.take(4)) Align(alignment: Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)), child: Text(c))), Row(children: [Expanded(child: TextField(controller: comment, decoration: const InputDecoration(hintText: 'Say something...', filled: true, fillColor: Color(0xFF131821)))), const SizedBox(width: 8), IconButton.filled(onPressed: () { if (comment.text.trim().isEmpty) return; setState(() { comments.insert(0, comment.text.trim()); comment.clear(); }); }, icon: const Icon(Icons.send)), const SizedBox(width: 6), IconButton.filled(onPressed: () {}, icon: const Icon(Icons.card_giftcard))])]))
  ]));
}
