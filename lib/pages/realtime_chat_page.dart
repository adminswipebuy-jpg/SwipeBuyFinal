import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/realtime_chat_service.dart';

class RealtimeChatPage extends StatefulWidget {
  final String otherUserId;
  final String? title;

  const RealtimeChatPage({
    super.key,
    required this.otherUserId,
    this.title,
  });

  @override
  State<RealtimeChatPage> createState() => _RealtimeChatPageState();
}

class _RealtimeChatPageState extends State<RealtimeChatPage> {
  final service = RealtimeChatService();
  final controller = TextEditingController();
  late final String conversationId;

  @override
  void initState() {
    super.initState();
    conversationId = service.conversationIdFor(widget.otherUserId);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text = controller.text;
    if (text.trim().isEmpty) return;
    await service.sendMessage(
      conversationId: conversationId,
      recipientId: widget.otherUserId,
      text: text,
    );
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: service.messages(conversationId),
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Center(child: Text('Unable to load messages.'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('Start the conversation.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc = docs[i];
                    final data = doc.data();
                    final mine = data['senderId'] == service.uid;
                    if (!mine) {
                      service.markMessageRead(conversationId, doc.id);
                    }
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: const BoxConstraints(maxWidth: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: mine ? Colors.orange : Colors.white10,
                        ),
                        child: Text(
                          data['text']?.toString() ?? '',
                          style: TextStyle(color: mine ? Colors.black : Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => send(),
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        filled: true,
                      ),
                    ),
                  ),
                  IconButton(onPressed: send, icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
