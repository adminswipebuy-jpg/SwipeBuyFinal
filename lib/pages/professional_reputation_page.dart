import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/reputation_service.dart';

class ProfessionalReputationPage extends StatefulWidget {
  final String providerId;
  final String providerName;
  const ProfessionalReputationPage({super.key, required this.providerId, this.providerName = 'Professional'});
  @override
  State<ProfessionalReputationPage> createState() => _ProfessionalReputationPageState();
}

class _ProfessionalReputationPageState extends State<ProfessionalReputationPage> {
  final service = ReputationService();
  int rating = 5;
  final review = TextEditingController();
  final orderId = TextEditingController();

  @override
  void dispose() { review.dispose(); orderId.dispose(); super.dispose(); }

  Future<void> _submit() async {
    try {
      await service.submitReview(providerId: widget.providerId, orderId: orderId.text.trim(), rating: rating, text: review.text.trim());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted for moderation.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.providerName} • Reputation')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.providerStats(widget.providerId),
        builder: (context, statsSnap) {
          final d = statsSnap.data?.docs.isNotEmpty == true ? statsSnap.data!.docs.first.data() : <String, dynamic>{};
          final avg = (d['averageRating'] as num?)?.toDouble() ?? 0;
          final count = (d['reviewCount'] as num?)?.toInt() ?? 0;
          final completed = (d['completedJobs'] as num?)?.toInt() ?? 0;
          final response = (d['responseRate'] as num?)?.toDouble();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.verified_user_outlined, size: 32), const SizedBox(width: 10), Expanded(child: Text(widget.providerName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))), const Icon(Icons.verified, color: Color(0xFF10B981))]),
                const SizedBox(height: 14),
                Row(children: [Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900)), const SizedBox(width: 8), const Icon(Icons.star, color: Colors.amber), Text('  $count reviews', style: const TextStyle(color: Colors.white70))]),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  Chip(label: Text('$completed completed jobs'), avatar: const Icon(Icons.task_alt_outlined, size: 18)),
                  if (response != null) Chip(label: Text('${response.toStringAsFixed(0)}% response'), avatar: const Icon(Icons.reply_outlined, size: 18)),
                  const Chip(label: Text('Trust signals'), avatar: Icon(Icons.shield_outlined, size: 18)),
                ]),
              ]))),
              const SizedBox(height: 12),
              Card(child: Column(children: [
                ListTile(leading: const Icon(Icons.rate_review_outlined), title: const Text('Write a verified review'), subtitle: const Text('Reviews are tied to a completed order/job and enter moderation before publishing.'), onTap: () => showDialog(context: context, builder: (_) => _reviewDialog())),
                const ListTile(leading: Icon(Icons.shield_outlined), title: Text('Reputation protection'), subtitle: Text('Disputes, review eligibility, fraud checks and provider enforcement should be decided by trusted backend services.')),
              ])),
              const SizedBox(height: 12),
              const Text('Recent published reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: service.providerReviews(widget.providerId),
                builder: (context, snap) {
                  if (snap.hasError) return const Card(child: ListTile(title: Text('Reviews unavailable')));
                  if (!snap.hasData) return const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()));
                  if (snap.data!.docs.isEmpty) return const Card(child: ListTile(title: Text('No published reviews yet.')));
                  return Column(children: snap.data!.docs.map((doc) {
                    final r = doc.data(); final score = (r['rating'] as num?)?.toInt() ?? 0;
                    return Card(child: ListTile(leading: CircleAvatar(child: Text('$score')), title: Row(children: List.generate(5, (i) => Icon(i < score ? Icons.star : Icons.star_border, size: 16, color: Colors.amber))), subtitle: Text(r['text']?.toString() ?? '')));
                  }).toList());
                },
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  AlertDialog _reviewDialog() => AlertDialog(
    title: const Text('Review professional'),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      DropdownButtonFormField<int>(value: rating, decoration: const InputDecoration(labelText: 'Rating'), items: [5,4,3,2,1].map((v) => DropdownMenuItem(value: v, child: Text('$v / 5'))).toList(), onChanged: (v) => setState(() => rating = v ?? 5)),
      TextField(controller: orderId, decoration: const InputDecoration(labelText: 'Completed job/order ID')),
      TextField(controller: review, maxLines: 4, decoration: const InputDecoration(labelText: 'Your review')),
    ])),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: _submit, child: const Text('Submit'))],
  );
}
