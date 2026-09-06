import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/marketing_growth_service.dart';

class MarketingGrowthPage extends StatefulWidget {
  const MarketingGrowthPage({super.key});
  @override
  State<MarketingGrowthPage> createState() => _MarketingGrowthPageState();
}

class _MarketingGrowthPageState extends State<MarketingGrowthPage> {
  final service = MarketingGrowthService();
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [_overview(), _campaigns(), _audiences(), _growth()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketing & Growth 2.0'),
        actions: [
          IconButton(
            tooltip: 'Refresh performance insights',
            onPressed: () async {
              await service.requestPerformanceInsights();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Performance insight request prepared.')),
                );
              }
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), label: 'Campaigns'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Audiences'),
          NavigationDestination(icon: Icon(Icons.trending_up_outlined), label: 'Growth'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCampaign,
        icon: const Icon(Icons.add),
        label: const Text('Campaign'),
      ),
    );
  }

  Widget _overview() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Marketing & Growth Intelligence', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Plan campaigns, connect customer intelligence and track growth from one merchant workspace.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: service.campaigns(),
            builder: (_, snap) {
              final count = snap.data?.docs.length ?? 0;
              return Row(children: [
                Expanded(child: _metric('Campaigns', '$count', Icons.campaign_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _metric('Channels', 'In-app • Email • WhatsApp', Icons.hub_outlined)),
              ]);
            },
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _metric('Goals', 'Sales • Leads • Retention', Icons.flag_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _metric('Signals', 'Reach • CTR • Orders', Icons.insights_outlined)),
          ]),
          const SizedBox(height: 14),
          _feature('Campaign builder', 'Create draft campaigns with an objective, audience, channel and budget before trusted backend delivery.', Icons.campaign_outlined),
          _feature('Audience activation', 'Connect CRM segments such as loyal buyers, high-intent shoppers and win-back audiences.', Icons.groups_outlined),
          _feature('Growth analytics', 'Track campaign reach, engagement, conversion and attributed orders when backend data is available.', Icons.analytics_outlined),
          _feature('Experimentation', 'Lay the groundwork for A/B tests, message variants and offer testing.', Icons.science_outlined),
          const SizedBox(height: 8),
          const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Production note: ad delivery, spend limits, consent, attribution, provider credentials and billing must be enforced by trusted backend services.', style: TextStyle(color: Colors.white70)))),
        ],
      );

  Widget _campaigns() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.campaigns(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              FilledButton.icon(onPressed: _createCampaign, icon: const Icon(Icons.add), label: const Text('Create campaign')),
              const SizedBox(height: 10),
              ...docs.map((d) {
                final x = d.data();
                return Card(child: ListTile(
                  leading: const Icon(Icons.campaign_outlined),
                  title: Text('${x['name'] ?? 'Untitled campaign'}'),
                  subtitle: Text('${x['objective'] ?? 'goal pending'} • ${x['channel'] ?? 'channel pending'} • ${x['audience'] ?? 'audience pending'}'),
                  trailing: Text('${x['status'] ?? 'draft'}'),
                ));
              }),
              if (docs.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No campaigns yet.'))),
            ],
          );
        },
      );

  Widget _audiences() => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _feature('Loyal customers', 'Activate repeat buyers with retention offers and early access.', Icons.favorite_outline),
          _feature('High-intent shoppers', 'Target users showing strong browse, save or checkout signals.', Icons.bolt_outlined),
          _feature('Win-back', 'Prepare permissioned re-engagement for inactive customers.', Icons.replay_outlined),
          _feature('New customers', 'Build onboarding campaigns around first purchase and product education.', Icons.person_add_alt_outlined),
          const Card(child: ListTile(leading: Icon(Icons.link_outlined), title: Text('CRM segment handoff'), subtitle: Text('Future campaigns can consume businessCustomerSegments through trusted backend audience services.'))),
        ],
      );

  Widget _growth() => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _metric('Primary growth loop', 'Discover → Engage → Buy → Return', Icons.autorenew_rounded),
          const SizedBox(height: 10),
          _feature('Acquisition', 'Measure discovery, landing views, clicks and first-time buyers.', Icons.person_add_outlined),
          _feature('Conversion', 'Compare product views, saves, checkout starts and completed orders.', Icons.shopping_cart_checkout_outlined),
          _feature('Retention', 'Connect repeat orders, customer health and win-back performance.', Icons.repeat_outlined),
          _feature('Referral', 'Prepare referral and creator-led growth measurement.', Icons.share_outlined),
          const SizedBox(height: 10),
          FilledButton.icon(onPressed: () async { await service.requestPerformanceInsights(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Growth insight request prepared.'))); }, icon: const Icon(Icons.insights_outlined), label: const Text('Request backend growth insights')),
        ],
      );

  Widget _metric(String title, String value, IconData icon) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), Text(title)])));

  Widget _feature(String title, String subtitle, IconData icon) => Card(child: ListTile(leading: Icon(icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle)));

  Future<void> _createCampaign() async {
    final name = TextEditingController();
    final audience = TextEditingController(text: 'loyal_customers');
    final budget = TextEditingController();
    var channel = 'in_app';
    var objective = 'sales';
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Create campaign draft'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Campaign name')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(value: objective, items: const [DropdownMenuItem(value: 'sales', child: Text('Sales')), DropdownMenuItem(value: 'leads', child: Text('Leads')), DropdownMenuItem(value: 'retention', child: Text('Retention')), DropdownMenuItem(value: 'awareness', child: Text('Awareness'))], onChanged: (v) => setLocal(() => objective = v ?? objective), decoration: const InputDecoration(labelText: 'Objective')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(value: channel, items: const [DropdownMenuItem(value: 'in_app', child: Text('In-app')), DropdownMenuItem(value: 'email', child: Text('Email')), DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp'))], onChanged: (v) => setLocal(() => channel = v ?? channel), decoration: const InputDecoration(labelText: 'Channel')),
            const SizedBox(height: 10),
            TextField(controller: audience, decoration: const InputDecoration(labelText: 'Audience / segment')),
            const SizedBox(height: 10),
            TextField(controller: budget, keyboardType: TextInputType.text, decoration: const InputDecoration(labelText: 'Budget / limit')),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save draft')),
          ],
        ),
      ),
    );
    if (saved == true) {
      await service.createCampaign(name: name.text, channel: channel, objective: objective, audience: audience.text, budget: budget.text);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Campaign draft created.')));
    }
    name.dispose();
    audience.dispose();
    budget.dispose();
  }
}
