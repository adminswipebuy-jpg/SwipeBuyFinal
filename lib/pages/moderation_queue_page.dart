import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ModerationQueuePage extends StatelessWidget {
  const ModerationQueuePage({super.key});

  Future<void> _resolve(BuildContext context, DocumentSnapshot<Map<String, dynamic>> doc, String status) async {
    await doc.reference.update({'status': status, 'reviewedAt': FieldValue.serverTimestamp()});
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report marked $status.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Moderation queue')),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('reports').where('status', isEqualTo: 'open').orderBy('createdAt', descending: true).limit(100).snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snap.hasError) return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Moderation queue unavailable: ${snap.error}')));
            final docs = snap.data?.docs ?? const [];
            if (docs.isEmpty) return const Center(child: Text('No open reports.'));
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final d = docs[i].data();
                return Card(color: const Color(0xFF111720), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text(d['targetType'] ?? 'content', style: const TextStyle(fontWeight: FontWeight.w900)), const Spacer(), Text(d['reason'] ?? 'other', style: const TextStyle(color: Colors.white60))]),
                  const SizedBox(height: 7),
                  Text('Target: ${d['targetId'] ?? ''}'),
                  if ((d['details'] ?? '').toString().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(d['details'], style: const TextStyle(color: Colors.white70))),
                  const SizedBox(height: 10),
                  Row(children: [
                    OutlinedButton(onPressed: () => _resolve(context, docs[i], 'dismissed'), child: const Text('Dismiss')),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: () => _resolve(context, docs[i], 'reviewed'), child: const Text('Resolve')),
                  ]),
                ])));
              },
            );
          },
        ),
      );
}
