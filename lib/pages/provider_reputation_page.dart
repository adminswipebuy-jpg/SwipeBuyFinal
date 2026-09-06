import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/reputation_service.dart';

class ProviderReputationPage extends StatelessWidget {
  final String providerId;
  final String providerName;

  const ProviderReputationPage({
    super.key,
    required this.providerId,
    this.providerName = 'Provider',
  });

  @override
  Widget build(BuildContext context) {
    final service = ReputationService();
    return Scaffold(
      appBar: AppBar(title: Text(providerName)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.providerStats(providerId),
        builder: (context, statsSnap) {
          double avg = 0;
          int count = 0;
          if (statsSnap.hasData && statsSnap.data!.docs.isNotEmpty) {
            final d = statsSnap.data!.docs.first.data();
            avg = (d['averageRating'] as num?)?.toDouble() ?? 0;
            count = (d['reviewCount'] as num?)?.toInt() ?? 0;
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, size: 34),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$avg / 5', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                        Text('$count reviews'),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: service.providerReviews(providerId),
                  builder: (context, snap) {
                    if (snap.hasError) return const Center(child: Text('Unable to load reviews.'));
                    if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                    final docs = snap.data!.docs;
                    if (docs.isEmpty) return const Center(child: Text('No published reviews yet.'));
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (_, i) {
                        final d = docs[i].data();
                        final rating = (d['rating'] as num?)?.toInt() ?? 0;
                        return ListTile(
                          leading: CircleAvatar(child: Text('$rating')),
                          title: Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                size: 17,
                              ),
                            ),
                          ),
                          subtitle: Text(d['text']?.toString() ?? ''),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
