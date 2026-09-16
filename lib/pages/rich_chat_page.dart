import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/rich_messaging_service.dart';

class RichChatPage extends StatefulWidget {
  final String otherUserId;
  final String title;
  const RichChatPage({super.key, required this.otherUserId, this.title = 'Chat'});
  @override State<RichChatPage> createState() => _RichChatPageState();
}

class _RichChatPageState extends State<RichChatPage> {
  final service = RichMessagingService();
  final controller = TextEditingController();
  final picker = ImagePicker();
  late final String conversationId;
  bool uploading = false;

  @override
  void initState() { super.initState(); conversationId = service.conversationIdFor(widget.otherUserId); }
  @override
  void dispose() { controller.dispose(); super.dispose(); }

  Future<void> sendText() async {
    final body = controller.text.trim();
    if (body.isEmpty) return;
    await service.send(conversationId: conversationId, recipientId: widget.otherUserId, text: body);
    controller.clear();
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (picked == null) return;
    setState(() => uploading = true);
    try {
      final url = await service.uploadAttachment(File(picked.path), kind: 'image');
      await service.send(conversationId: conversationId, recipientId: widget.otherUserId, type: 'image', mediaUrl: url);
    } finally { if (mounted) setState(() => uploading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900)), actions: [
      PopupMenuButton<String>(onSelected: (v) async { if (v == 'block') { await service.blockUser(widget.otherUserId); if (mounted) Navigator.pop(context); } }, itemBuilder: (_) => const [PopupMenuItem(value: 'block', child: Text('Block user'))]),
    ]),
    body: Column(children: [
      Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.messages(conversationId),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Unable to load messages.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('Start the conversation.'));
          return ListView.builder(itemCount: docs.length, padding: const EdgeInsets.all(12), itemBuilder: (_, i) {
            final d = docs[i].data();
            final mine = d['senderId'] == service.uid;
            if (!mine && !(List<String>.from(d['readBy'] ?? const []).contains(service.uid))) {
              service.markRead(conversationId: conversationId, messageId: docs[i].id);
            }
            final type = d['type']?.toString() ?? 'text';
            return Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft, child: GestureDetector(
              onLongPress: () => _react(context, docs[i].id),
              child: Container(margin: const EdgeInsets.symmetric(vertical: 4), padding: const EdgeInsets.all(10), constraints: const BoxConstraints(maxWidth: 310), decoration: BoxDecoration(color: mine ? Colors.orange : Colors.white10, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (type == 'image' && d['mediaUrl'] != null) ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(d['mediaUrl'], fit: BoxFit.cover)),
                if ((d['text'] ?? '').toString().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 5), child: Text(d['text'].toString(), style: TextStyle(color: mine ? Colors.black : Colors.white))),
                if (d['reactions'] is Map && (d['reactions'] as Map).isNotEmpty) Text((d['reactions'] as Map).values.join(' '), style: const TextStyle(fontSize: 13)),
              ])),
            ));
          });
        },
      )),
      if (uploading) const LinearProgressIndicator(minHeight: 2),
      SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(10, 6, 10, 10), child: Row(children: [
        IconButton(onPressed: uploading ? null : pickImage, icon: const Icon(Icons.photo_outlined)),
        Expanded(child: TextField(controller: controller, onChanged: (v) => service.setTyping(conversationId: conversationId, typing: v.isNotEmpty), onSubmitted: (_) => sendText(), decoration: const InputDecoration(hintText: 'Message...', filled: true))),
        IconButton(onPressed: sendText, icon: const Icon(Icons.send)),
      ]))),
    ]),
  );

  Future<void> _react(BuildContext context, String messageId) async {
    await showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: ['❤️','😂','🔥','👍','😮'].map((e) => IconButton(onPressed: () { Navigator.pop(context); service.react(conversationId: conversationId, messageId: messageId, emoji: e); }, icon: Text(e, style: const TextStyle(fontSize: 26)))).toList())));
  }
}
