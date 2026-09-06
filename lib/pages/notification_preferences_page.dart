import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});
  @override
  State<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends State<NotificationPreferencesPage> {
  bool likes = true;
  bool comments = true;
  bool follows = true;
  bool messages = true;
  bool live = true;
  bool jobs = true;
  bool market = true;
  bool recommendations = true;
  bool saving = false;

  DocumentReference<Map<String, dynamic>> get ref => FirebaseFirestore.instance
      .collection('users').doc(FirebaseAuth.instance.currentUser?.uid ?? '')
      .collection('settings').doc('notifications');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap = await ref.get();
    if (!mounted || !snap.exists) return;
    final d = snap.data()!;
    setState(() {
      likes = d['likes'] ?? likes;
      comments = d['comments'] ?? comments;
      follows = d['follows'] ?? follows;
      messages = d['messages'] ?? messages;
      live = d['live'] ?? live;
      jobs = d['jobs'] ?? jobs;
      market = d['market'] ?? market;
      recommendations = d['recommendations'] ?? recommendations;
    });
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => saving = true);
    try {
      await ref.set({
        'likes': likes,
        'comments': comments,
        'follows': follows,
        'messages': messages,
        'live': live,
        'jobs': jobs,
        'market': market,
        'recommendations': recommendations,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification preferences saved.')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Notification settings')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            const Text('Stay in control', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('Choose the alerts that matter to you. SwipeBuy will use these preferences across your For You feed and notifications.', style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 18),
            _section('Social', [
              _tile('Likes', likes, (v) => setState(() => likes = v)),
              _tile('Comments', comments, (v) => setState(() => comments = v)),
              _tile('New followers', follows, (v) => setState(() => follows = v)),
              _tile('Messages', messages, (v) => setState(() => messages = v)),
            ]),
            _section('Discovery', [
              _tile('LIVE alerts', live, (v) => setState(() => live = v)),
              _tile('Job opportunities', jobs, (v) => setState(() => jobs = v)),
              _tile('Forex / crypto / market alerts', market, (v) => setState(() => market = v)),
              _tile('Personalized recommendations', recommendations, (v) => setState(() => recommendations = v)),
            ]),
            const SizedBox(height: 12),
            SizedBox(height: 52, child: FilledButton(onPressed: saving ? null : _save, child: saving ? const CircularProgressIndicator() : const Text('Save preferences', style: TextStyle(fontWeight: FontWeight.w900)))),
          ],
        ),
      );

  Widget _section(String title, List<Widget> children) => Card(
        color: const Color(0xFF111720),
        margin: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 6), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900))),
          ...children,
        ]),
      );

  Widget _tile(String title, bool value, ValueChanged<bool> onChanged) => SwitchListTile.adaptive(
        title: Text(title),
        value: value,
        onChanged: onChanged,
      );
}
