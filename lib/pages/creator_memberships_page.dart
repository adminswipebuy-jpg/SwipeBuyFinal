import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/creator_membership_service.dart';

class CreatorMembershipsPage extends StatefulWidget {
  const CreatorMembershipsPage({super.key});
  @override
  State<CreatorMembershipsPage> createState() => _CreatorMembershipsPageState();
}

class _CreatorMembershipsPageState extends State<CreatorMembershipsPage> {
  final service = CreatorMembershipService();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Creator Memberships 2.0'),
          actions: [
            IconButton(
              tooltip: 'Safety guidance',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Membership safety'),
                  content: Text('Trusted backend systems must verify payments, renewals, refunds, entitlements, taxes and premium-content access. This screen only creates requests and settings.'),
                ),
              ),
              icon: const Icon(Icons.verified_user_outlined),
            ),
          ],
        ),
        body: DefaultTabController(
          length: 2,
          child: Column(children: [
            const TabBar(tabs: [Tab(text: 'Creator'), Tab(text: 'My memberships')]),
            Expanded(child: TabBarView(children: [_creatorView(), _memberView()])),
          ]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createPlan,
          icon: const Icon(Icons.add),
          label: const Text('Membership plan'),
        ),
      );

  Widget _creatorView() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Build a fan community', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Offer premium perks, members-only content and community access while keeping billing and entitlements backend-controlled.', style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _metric('Premium access', 'Content • Perks • Community', Icons.workspace_premium_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _metric('Creator controls', 'Plans • Members • Payouts', Icons.dashboard_outlined)),
          ]),
          const SizedBox(height: 14),
          _feature('Members-only content', 'Gate posts, videos, LIVE rooms and community experiences after backend entitlement checks.', Icons.lock_outline),
          _feature('Fan perks', 'Define badges, early access, discounts, private chats or custom benefits.', Icons.card_giftcard_outlined),
          _feature('Membership tiers', 'Create multiple levels with clear pricing and perks.', Icons.layers_outlined),
          _feature('Creator earnings', 'Track membership revenue and request payouts through trusted backend/payment systems.', Icons.payments_outlined),
          const SizedBox(height: 14),
          const Text('My plans', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: service.myPlans(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
              final docs = snap.data?.docs ?? const [];
              if (docs.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No membership plans yet. Create your first tier.')));
              return Column(children: docs.map((d) {
                final x = d.data();
                return Card(child: ListTile(
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: Text(x['name']?.toString() ?? 'Membership'),
                  subtitle: Text('${x['currency'] ?? 'USD'} ${x['monthlyPrice'] ?? 0} / month • ${x['status'] ?? 'draft'}'),
                  trailing: IconButton(icon: const Icon(Icons.copy_outlined), onPressed: () => _copyPlanId(d.id)),
                ));
              }).toList());
            },
          ),
        ],
      );

  Widget _memberView() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Your memberships', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Membership purchases are requested here; payment and entitlement activation must happen through trusted backend systems.', style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 14),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: service.myMemberships(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
              final docs = snap.data?.docs ?? const [];
              if (docs.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No active memberships yet. Explore creators and join a membership from their profile.')));
              return Column(children: docs.map((d) {
                final x = d.data();
                return Card(child: ListTile(
                  leading: const Icon(Icons.verified_outlined),
                  title: Text(x['creatorName']?.toString() ?? 'Creator membership'),
                  subtitle: Text('${x['planName'] ?? 'Premium'} • ${x['status'] ?? 'active'}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'cancel') {
                        await service.cancelMembership(d.id);
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cancellation request sent.')));
                      }
                    },
                    itemBuilder: (_) => const [PopupMenuItem(value: 'cancel', child: Text('Request cancellation'))],
                  ),
                ));
              }).toList());
            },
          ),
        ],
      );

  Widget _metric(String title, String value, IconData icon) => Card(
        color: const Color(0xFF12382E),
        child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: const Color(0xFF38D9A9)), const SizedBox(height: 8), Text(value, style: const TextStyle(fontWeight: FontWeight.w900)), Text(title, style: const TextStyle(color: Colors.white60))])),
      );

  Widget _feature(String title, String subtitle, IconData icon) => Card(child: ListTile(leading: Icon(icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle)));

  Future<void> _copyPlanId(String id) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(title: const Text('Plan ID'), content: SelectableText(id), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]),
    );
  }

  Future<void> _createPlan() async {
    final name = TextEditingController();
    final description = TextEditingController();
    final price = TextEditingController(text: '5');
    final perks = TextEditingController(text: 'Members-only posts, early access and premium chat');
    String currency = 'USD';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
        title: const Text('Create membership plan'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Plan name')),
          const SizedBox(height: 10),
          TextField(controller: description, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 10),
          TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly price')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(initialValue: currency, items: const ['USD', 'GHS', 'NGN', 'KES', 'GBP', 'EUR'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setLocal(() => currency = v ?? currency), decoration: const InputDecoration(labelText: 'Currency')),
          const SizedBox(height: 10),
          TextField(controller: perks, maxLines: 3, decoration: const InputDecoration(labelText: 'Perks')),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))],
      )),
    );
    if (ok != true) return;
    try {
      final amount = double.tryParse(price.text.trim()) ?? -1;
      final id = await service.createPlan(name: name.text, description: description.text, monthlyPrice: amount, currency: currency, perks: perks.text);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Plan created as draft: $id')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
