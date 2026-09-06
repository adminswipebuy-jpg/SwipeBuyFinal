import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/business_service.dart';
import '../services/monetization_service.dart';
import 'advertising_page.dart';
import 'creator_studio_page.dart';
import 'inventory_management_page.dart';
import 'wallet_page.dart';
import 'analytics_page.dart';
import 'creator_brand_partnerships_page.dart';

class CommandCenterPage extends StatelessWidget {
  const CommandCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Command Center', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: () => _open(context, const WalletPage()), icon: const Icon(Icons.account_balance_wallet_outlined)),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('Sign in to use your Command Center.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
              children: [
                const Text('Run your SwipeBuy presence', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text('One workspace for content, audience, sales, bookings, ads and earnings.', style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 18),
                _OverviewGrid(uid: uid),
                const SizedBox(height: 18),
                _QuickActions(),
                const SizedBox(height: 18),
                _LiveActivity(uid: uid),
                const SizedBox(height: 18),
                _PerformanceCard(uid: uid),
              ],
            ),
    );
  }

  static void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _OverviewGrid extends StatelessWidget {
  final String uid;
  const _OverviewGrid({required this.uid});

  @override
  Widget build(BuildContext context) {
    final business = BusinessService();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: business.myListings(),
      builder: (context, listingSnap) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: business.myOrders(),
          builder: (context, orderSnap) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: MonetizationService().creatorEarnings(),
              builder: (context, earningSnap) {
                final listings = listingSnap.data?.docs.length ?? 0;
                final orders = orderSnap.data?.docs.length ?? 0;
                double earnings = 0;
                for (final d in earningSnap.data?.docs ?? const []) {
                  final raw = d.data()['amount'];
                  earnings += raw is num ? raw.toDouble() : double.tryParse(raw?.toString() ?? '') ?? 0;
                }
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.55,
                  children: [
                    _MetricCard(label: 'Listings', value: '$listings', icon: Icons.inventory_2_outlined, accent: const Color(0xFF38D9A9)),
                    _MetricCard(label: 'Orders', value: '$orders', icon: Icons.shopping_bag_outlined, accent: Colors.orange),
                    _MetricCard(label: 'Creator earnings', value: 'GHS ${earnings.toStringAsFixed(2)}', icon: Icons.monetization_on_outlined, accent: Colors.amber),
                    _MetricCard(label: 'Workspace status', value: 'Active', icon: Icons.verified_outlined, accent: Colors.lightBlue),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  const _MetricCard({required this.label, required this.value, required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111720),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: accent),
          const Spacer(),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 3),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ]),
      );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = <({String label, IconData icon, Widget page})>[
      (label: 'Create', icon: Icons.add_a_photo_outlined, page: const CreatorStudioPage()),
      (label: 'Inventory', icon: Icons.inventory_2_outlined, page: const InventoryManagementPage()),
      (label: 'Ads', icon: Icons.campaign_outlined, page: const AdvertisingPage()),
      (label: 'Wallet', icon: Icons.account_balance_wallet_outlined, page: const WalletPage()),
      (label: 'Analytics', icon: Icons.analytics_outlined, page: const AnalyticsPage()),
      (label: 'Partners', icon: Icons.handshake_outlined, page: const CreatorBrandPartnershipsPage()),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Quick actions', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: actions.map((a) => SizedBox(
          width: 120,
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => a.page)),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF111720),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Icon(a.icon, color: const Color(0xFF38D9A9)),
                  const SizedBox(height: 7),
                  Text(a.label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                ],
              ),
            ),
          ),
        )).toList(),
      ),
    ]);
  }
}

class _LiveActivity extends StatelessWidget {
  final String uid;
  const _LiveActivity({required this.uid});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Latest activity', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db.collection('ad_campaigns').where('ownerId', isEqualTo: uid).limit(5).snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? const [];
          if (docs.isEmpty) return _activityEmpty('Your latest campaigns and promotions will appear here.');
          return Card(color: const Color(0xFF111720), child: Column(children: docs.map((d) {
            final data = d.data();
            return ListTile(leading: const Icon(Icons.campaign_outlined), title: Text(data['name']?.toString() ?? 'Campaign'), subtitle: Text(data['status']?.toString() ?? 'draft'), trailing: Text('GHS ${data['dailyBudget'] ?? 0}'));
          }).toList()));
        },
      ),
    ]);
  }

  Widget _activityEmpty(String text) => Card(color: const Color(0xFF111720), child: Padding(padding: const EdgeInsets.all(18), child: Text(text, style: const TextStyle(color: Colors.white60))));
}

class _PerformanceCard extends StatelessWidget {
  final String uid;
  const _PerformanceCard({required this.uid});

  @override
  Widget build(BuildContext context) => Card(
        color: const Color(0xFF12382E),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.insights_outlined, color: Color(0xFF38D9A9)), SizedBox(width: 8), Text('AI insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))]),
            const SizedBox(height: 8),
            const Text('Use your content, audience and transaction signals to decide what to publish, promote or improve next.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _Pill('Best content'), _Pill('Audience growth'), _Pill('Sales opportunities'), _Pill('Ad performance'),
            ]),
          ]),
        ),
      );
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(99)), child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)));
}
