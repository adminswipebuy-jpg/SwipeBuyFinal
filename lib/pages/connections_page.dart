import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/social_service.dart';
import 'creator_discovery_page.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});
  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _social = SocialService();
  final _search = TextEditingController();
  int _tab = 0;

  String get uid => _auth.currentUser?.uid ?? '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _follows({required bool followers}) {
    if (uid.isEmpty) {
      return _db.collection('follows').where(followers ? 'providerId' : 'followerId', isEqualTo: '__none__').snapshots();
    }
    return _db.collection('follows').where(followers ? 'providerId' : 'followerId', isEqualTo: uid).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _user(String id) => _db.collection('users').doc(id).get();

  bool _matches(Map<String, dynamic> data, String query) {
    if (query.trim().isEmpty) return true;
    final q = query.trim().toLowerCase();
    return '${data['displayName'] ?? ''} ${data['username'] ?? ''} ${data['bio'] ?? ''}'.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connections'),
        actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatorDiscoveryPage())), icon: const Icon(Icons.explore_outlined)), IconButton(onPressed: () => showSearch(context: context, delegate: _ConnectionSearchDelegate(db: _db, currentUid: uid)), icon: const Icon(Icons.search))]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Filter connections', suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.clear))))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Row(children: [Expanded(child: _tabButton(0, 'Following', Icons.person_add_alt_1_outlined)), const SizedBox(width: 8), Expanded(child: _tabButton(1, 'Followers', Icons.people_outline))])),
        const Divider(height: 1),
        Expanded(child: _tab == 0 ? _list(followers: false) : _list(followers: true)),
      ]),
    );
  }

  Widget _tabButton(int index, String label, IconData icon) => FilledButton.icon(
    onPressed: () => setState(() => _tab = index),
    icon: Icon(icon, size: 18), label: Text(label),
    style: FilledButton.styleFrom(backgroundColor: _tab == index ? Theme.of(context).colorScheme.primary : Colors.white10, foregroundColor: Colors.white),
  );

  Widget _list({required bool followers}) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: _follows(followers: followers),
    builder: (context, snap) {
      if (snap.hasError) return const Center(child: Text('Unable to load connections.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final refs = snap.data!.docs;
      if (refs.isEmpty) return Center(child: Text(followers ? 'No followers yet.' : 'You are not following anyone yet.'));
      return ListView.builder(
        itemCount: refs.length,
        itemBuilder: (_, i) {
          final data = refs[i].data();
          final id = (followers ? data['followerId'] : data['providerId'])?.toString() ?? '';
          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(future: _user(id), builder: (_, userSnap) {
            if (!userSnap.hasData) return const ListTile(leading: CircleAvatar(child: Icon(Icons.person)), title: Text('Loading…'));
            final user = userSnap.data!.data() ?? <String, dynamic>{};
            if (!_matches(user, _search.text)) return const SizedBox.shrink();
            final name = (user['displayName'] ?? user['username'] ?? 'SwipeBuy User').toString();
            final bio = (user['bio'] ?? 'SwipeBuy connection').toString();
            return ListTile(
              leading: CircleAvatar(child: Text(name.isEmpty ? 'S' : name.substring(0, 1).toUpperCase())),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(bio, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: followers || id.isEmpty ? null : StreamBuilder<bool>(stream: _social.isFollowing(id), builder: (_, s) => OutlinedButton(onPressed: s.data == true ? () => _social.unfollowProvider(id) : () => _social.followProvider(id), child: Text(s.data == true ? 'Following' : 'Follow'))),
            );
          });
        },
      );
    },
  );
}

class _ConnectionSearchDelegate extends SearchDelegate<String> {
  final FirebaseFirestore db;
  final String currentUid;
  _ConnectionSearchDelegate({required this.db, required this.currentUid});

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(onPressed: () => close(context, ''), icon: const Icon(Icons.arrow_back));
  @override
  Widget buildResults(BuildContext context) => _results();
  @override
  Widget buildSuggestions(BuildContext context) => _results();

  Widget _results() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: db.collection('users').limit(40).snapshots(),
    builder: (context, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final q = query.trim().toLowerCase();
      final docs = snap.data!.docs.where((d) {
        if (d.id == currentUid) return false;
        final m = d.data();
        return '${m['displayName'] ?? ''} ${m['username'] ?? ''}'.toLowerCase().contains(q);
      }).toList();
      if (docs.isEmpty) return const Center(child: Text('No users found.'));
      return ListView(children: docs.map((d) {
        final m = d.data();
        return ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text((m['displayName'] ?? m['username'] ?? 'SwipeBuy User').toString()), subtitle: Text('@${(m['username'] ?? '').toString()}'));
      }).toList());
    },
  );
}
