import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/business_crm_service.dart';

class BusinessCrmPage extends StatefulWidget {
  const BusinessCrmPage({super.key});
  @override
  State<BusinessCrmPage> createState() => _BusinessCrmPageState();
}

class _BusinessCrmPageState extends State<BusinessCrmPage> {
  final service = BusinessCrmService();
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [_overview(), _customers(), _segments(), _outreach()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business CRM 2.0'),
        actions: [
          IconButton(
            tooltip: 'Refresh insights',
            onPressed: () async {
              await service.requestInsightsRefresh();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CRM insight refresh requested.')));
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
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), label: 'Customers'),
          NavigationDestination(icon: Icon(Icons.segment_outlined), label: 'Segments'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), label: 'Outreach'),
        ],
      ),
    );
  }

  Widget _overview() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Customer Intelligence', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Understand customers, build segments and prepare safer outreach from one workspace.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _countCard('Customers', service.customers(), Icons.people_alt_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _countCard('Interactions', service.interactions(), Icons.forum_outlined)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _countCard('Segments', service.segments(), Icons.segment_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _metric('Signals', 'Views • chats • orders', Icons.insights_outlined)),
          ]),
          const SizedBox(height: 14),
          _feature('Customer 360 foundation', 'Unify orders, conversations, reviews and engagement signals around customer records.', Icons.person_search_outlined),
          _feature('Smart segments', 'Create reusable groups such as loyal buyers, inactive customers and high-intent shoppers.', Icons.filter_alt_outlined),
          _feature('Retention intelligence', 'Surface repeat-purchase, churn-risk and customer-value signals for future backend models.', Icons.trending_up_outlined),
          _feature('Outreach workflows', 'Prepare email, WhatsApp or in-app outreach through permissioned backend delivery.', Icons.campaign_outlined),
          const SizedBox(height: 8),
          const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Production note: customer data access, bulk outreach, consent, rate limits and messaging delivery should be enforced by trusted backend services.', style: TextStyle(color: Colors.white70)))),
        ],
      );

  Widget _customers() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.customers(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(child: ListTile(leading: const Icon(Icons.insights_outlined), title: const Text('Customer health'), subtitle: const Text('Use recency, frequency and value signals when available.'))),
              ...docs.map((d) {
                final x = d.data();
                return Card(child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                  title: Text('${x['displayName'] ?? x['name'] ?? 'Customer'}'),
                  subtitle: Text('Orders: ${x['ordersCount'] ?? 0} • Spend: ${x['lifetimeValue'] ?? 0} • Last seen: ${x['lastSeen'] ?? '—'}'),
                  trailing: const Icon(Icons.chevron_right),
                ));
              }),
              if (docs.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Customer profiles will appear here after backend sync.'))),
            ],
          );
        },
      );

  Widget _segments() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.segments(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              FilledButton.icon(onPressed: _createSegment, icon: const Icon(Icons.add), label: const Text('Create segment')),
              const SizedBox(height: 10),
              ...docs.map((d) {
                final x = d.data();
                return Card(child: ListTile(leading: const Icon(Icons.segment_outlined), title: Text('${x['name'] ?? 'Unnamed segment'}'), subtitle: Text('${x['rule'] ?? 'Rule pending'} • ${x['status'] ?? 'draft'}')));
              }),
              if (docs.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No customer segments yet.'))),
            ],
          );
        },
      );

  Widget _outreach() => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Card(child: ListTile(leading: Icon(Icons.shield_outlined), title: Text('Consent-aware outreach'), subtitle: Text('Prepare campaigns here; backend services should enforce customer consent and delivery limits.'))),
          FilledButton.icon(onPressed: _queueOutreach, icon: const Icon(Icons.send_outlined), label: const Text('Prepare outreach request')),
          const SizedBox(height: 12),
          _feature('WhatsApp', 'Prepare targeted customer messages through an approved provider.', Icons.chat_outlined),
          _feature('Email', 'Prepare segmented email campaigns with unsubscribe support.', Icons.email_outlined),
          _feature('In-app', 'Prepare personalized notifications for opted-in customers.', Icons.notifications_active_outlined),
        ],
      );

  Widget _countCard(String title, Stream<QuerySnapshot<Map<String, dynamic>>> stream, IconData icon) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (_, snap) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon), const SizedBox(height: 8), Text('${snap.data?.docs.length ?? 0}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), Text(title)]))),
      );

  Widget _metric(String title, String value, IconData icon) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), Text(title)])));

  Widget _feature(String title, String subtitle, IconData icon) => Card(child: ListTile(leading: Icon(icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle)));

  Future<void> _createSegment() async {
    final name = TextEditingController();
    final rule = TextEditingController(text: 'high_intent');
    final saved = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Create customer segment'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Segment name')), const SizedBox(height: 10), TextField(controller: rule, decoration: const InputDecoration(labelText: 'Rule / signal'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))]));
    if (saved == true) {
      await service.createSegment(name: name.text, rule: rule.text);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer segment created.')));
    }
    name.dispose();
    rule.dispose();
  }

  Future<void> _queueOutreach() async {
    final message = TextEditingController();
    var channel = 'in_app';
    final saved = await showDialog<bool>(context: context, builder: (_) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(title: const Text('Prepare outreach'), content: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButtonFormField<String>(value: channel, items: const [DropdownMenuItem(value: 'in_app', child: Text('In-app')), DropdownMenuItem(value: 'email', child: Text('Email')), DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp'))], onChanged: (v) => setLocal(() => channel = v ?? channel), decoration: const InputDecoration(labelText: 'Channel')), const SizedBox(height: 10), TextField(controller: message, maxLines: 3, decoration: const InputDecoration(labelText: 'Message'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Prepare'))])));
    if (saved == true) {
      await service.queueOutreach(channel: channel, segmentId: '', message: message.text);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Outreach request prepared for backend processing.')));
    }
    message.dispose();
  }
}
