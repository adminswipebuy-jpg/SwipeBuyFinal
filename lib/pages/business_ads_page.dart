import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/business_ads_service.dart';

class BusinessAdsPage extends StatefulWidget {
  const BusinessAdsPage({super.key});
  @override
  State<BusinessAdsPage> createState() => _BusinessAdsPageState();
}

class _BusinessAdsPageState extends State<BusinessAdsPage> {
  final service = BusinessAdsService();
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [_overview(), _campaigns(), _audience(), _analytics()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Ads Platform 2.0'),
        actions: [
          IconButton(
            tooltip: 'Request forecast',
            onPressed: () async {
              await service.requestAdForecast();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ad forecast request prepared.')));
            },
            icon: const Icon(Icons.insights_outlined),
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
          NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Audience'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCampaign,
        icon: const Icon(Icons.add),
        label: const Text('Ad campaign'),
      ),
    );
  }

  Widget _overview() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Business Ads Platform', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Prepare, review and measure advertising across the SwipeBuy ecosystem.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: service.campaigns(),
            builder: (_, snap) {
              final count = snap.data?.docs.length ?? 0;
              return Row(children: [
                Expanded(child: _metric('Campaigns', '$count', Icons.campaign_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _metric('Placements', 'Feed • Search • Video • LIVE', Icons.view_carousel_outlined)),
              ]);
            },
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _metric('Goals', 'Awareness • Leads • Sales', Icons.flag_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _metric('Controls', 'Budget • Consent • Review', Icons.tune_outlined)),
          ]),
          const SizedBox(height: 14),
          _feature('Omnichannel placements', 'Prepare campaigns for feed, search, short video and LIVE surfaces from one workspace.', Icons.hub_outlined),
          _feature('Budget guardrails', 'Define limits before backend launch and provider billing are applied.', Icons.account_balance_wallet_outlined),
          _feature('Audience controls', 'Connect consent-aware CRM segments without exposing raw customer data to the client.', Icons.groups_outlined),
          _feature('Attribution', 'Measure impressions, clicks, conversions and attributed orders when trusted backend data is available.', Icons.insights_outlined),
          _feature('Experimentation', 'Prepare creative or audience variants for controlled A/B testing.', Icons.science_outlined),
          const SizedBox(height: 8),
          const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Production note: ad serving, fraud checks, consent enforcement, spend caps, billing, targeting eligibility and attribution must be enforced by trusted backend systems.', style: TextStyle(color: Colors.white70)))),
        ],
      );

  Widget _campaigns() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.campaigns(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              FilledButton.icon(onPressed: _createCampaign, icon: const Icon(Icons.add), label: const Text('Create ad campaign draft')),
              const SizedBox(height: 10),
              ...docs.map((d) {
                final x = d.data();
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.campaign_outlined),
                    title: Text('${x['name'] ?? 'Untitled ad campaign'}'),
                    subtitle: Text('${x['objective'] ?? 'objective pending'} • ${x['placement'] ?? 'placement pending'} • ${x['audience'] ?? 'audience pending'}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'launch') {
                          await service.requestLaunch(d.id);
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Launch request sent for backend review.')));
                        }
                      },
                      itemBuilder: (_) => const [PopupMenuItem(value: 'launch', child: Text('Request launch'))],
                    ),
                  ),
                );
              }),
              if (docs.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No ad campaigns yet.'))),
            ],
          );
        },
      );

  Widget _audience() => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _feature('Broad discovery', 'Reach new audiences across relevant SwipeBuy discovery surfaces.', Icons.explore_outlined),
          _feature('High-intent shoppers', 'Use purchase-intent signals only through privacy-safe backend audience services.', Icons.bolt_outlined),
          _feature('Retargeting', 'Reconnect with eligible users who viewed, saved or started checkout for a permitted offer.', Icons.replay_outlined),
          _feature('Lookalike foundation', 'Prepare privacy-safe similarity audiences without exporting raw customer lists to the app.', Icons.groups_3_outlined),
          _feature('Consent and eligibility', 'Backend should verify region, consent, age/eligibility and policy before activation.', Icons.verified_user_outlined),
        ],
      );

  Widget _analytics() => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _metric('Primary funnel', 'Impression → View → Click → Conversion', Icons.trending_up_outlined),
          const SizedBox(height: 10),
          _feature('Reach', 'Unique eligible audience reached by the campaign.', Icons.people_outline),
          _feature('Engagement', 'Views, clicks, watch time and meaningful interactions.', Icons.touch_app_outlined),
          _feature('Conversion', 'Attributed purchases, leads or other configured goals.', Icons.shopping_cart_checkout_outlined),
          _feature('Efficiency', 'CPA, ROAS and other economics when verified backend spend and revenue data exist.', Icons.calculate_outlined),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () async {
              await service.requestAdForecast();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Forecast request prepared.')));
            },
            icon: const Icon(Icons.auto_graph_outlined),
            label: const Text('Request backend ad forecast'),
          ),
        ],
      );

  Widget _metric(String title, String value, IconData icon) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), Text(title)]),
        ),
      );

  Widget _feature(String title, String subtitle, IconData icon) => Card(
        child: ListTile(leading: Icon(icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle)),
      );

  Future<void> _createCampaign() async {
    final name = TextEditingController();
    final audience = TextEditingController(text: 'high_intent_shoppers');
    final budget = TextEditingController();
    var placement = 'feed';
    var objective = 'sales';
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Create ad campaign draft'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Campaign name')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(initialValue: objective, items: const [
                DropdownMenuItem(value: 'sales', child: Text('Sales')),
                DropdownMenuItem(value: 'leads', child: Text('Leads')),
                DropdownMenuItem(value: 'awareness', child: Text('Awareness')),
                DropdownMenuItem(value: 'app_installs', child: Text('App installs')),
              ], onChanged: (v) => setLocal(() => objective = v ?? objective), decoration: const InputDecoration(labelText: 'Objective')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(initialValue: placement, items: const [
                DropdownMenuItem(value: 'feed', child: Text('Feed')),
                DropdownMenuItem(value: 'search', child: Text('Search')),
                DropdownMenuItem(value: 'short_video', child: Text('Short video')),
                DropdownMenuItem(value: 'live', child: Text('LIVE')),
              ], onChanged: (v) => setLocal(() => placement = v ?? placement), decoration: const InputDecoration(labelText: 'Placement')),
              const SizedBox(height: 10),
              TextField(controller: audience, decoration: const InputDecoration(labelText: 'Audience / segment')),
              const SizedBox(height: 10),
              TextField(controller: budget, decoration: const InputDecoration(labelText: 'Budget / spend limit')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save draft')),
          ],
        ),
      ),
    );
    if (saved != true || name.text.trim().isEmpty) return;
    await service.createDraft(name: name.text, objective: objective, placement: placement, audience: audience.text, budget: budget.text);
  }
}
