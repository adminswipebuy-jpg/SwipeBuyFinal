import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/following_feed_service.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  final _service = FollowingFeedService();
  late Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchFollowingListings();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.fetchFollowingListings());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Following')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.hasError) return ListView(children: const [
              SizedBox(height: 180),
              Center(child: Text('Unable to load your following feed.')),
            ]);
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!;
            if (docs.isEmpty) return ListView(children: const [
              SizedBox(height: 180),
              Center(child: Text('Follow providers to build your feed.')),
            ]);

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final d = docs[i].data();
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.play_circle_outline),
                    title: Text(d['title']?.toString() ?? 'SwipeBuy listing'),
                    subtitle: Text(d['category']?.toString() ?? 'Marketplace'),
                    trailing: Text(d['actionLabel']?.toString() ?? 'View'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
