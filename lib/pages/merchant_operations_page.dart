import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/merchant_operations_service.dart';

class MerchantOperationsPage extends StatefulWidget {
  const MerchantOperationsPage({super.key});
  @override
  State<MerchantOperationsPage> createState() => _MerchantOperationsPageState();
}

class _MerchantOperationsPageState extends State<MerchantOperationsPage> {
  final service = MerchantOperationsService();
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [_overview(), _inventory(), _fulfillment(), _returns(), _team()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Operations'),
        actions: [
          IconButton(
            tooltip: 'Sync operations',
            onPressed: () async {
              await service.requestOperationalSync();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operations sync requested.')));
            },
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), label: 'Fulfillment'),
          NavigationDestination(icon: Icon(Icons.assignment_return_outlined), label: 'Returns'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Team'),
        ],
      ),
    );
  }

  Widget _overview() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Merchant Operations', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Run catalog, fulfillment, returns and team workflows from one control room.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _countCard('SKUs', service.inventory(), Icons.inventory_2_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _countCard('Tasks', service.fulfillmentTasks(), Icons.local_shipping_outlined)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _countCard('Returns', service.returnRequests(), Icons.assignment_return_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _metricText('Merchant ID', AuthService.currentUser?.uid.substring(0, 8) ?? 'guest', Icons.badge_outlined)),
          ]),
          const SizedBox(height: 14),
          _feature('Inventory controls', 'Monitor stock, low-stock thresholds, SKU readiness and active catalog items.', Icons.inventory_2_outlined),
          _feature('Fulfillment orchestration', 'Queue packing, pickup and carrier handoff tasks against confirmed orders.', Icons.route_outlined),
          _feature('Returns operations', 'See incoming return requests and hand them off to trusted backend workflows.', Icons.assignment_return_outlined),
          _feature('Merchant team', 'Invite operators with scoped roles for safer multi-person store management.', Icons.groups_outlined),
          const SizedBox(height: 8),
          const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Production note: inventory deductions, refunds, shipment state and financial settlement should be enforced server-side, not trusted to the client.', style: TextStyle(color: Colors.white70)))),
        ],
      );

  Widget _inventory() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.inventory(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          final low = docs.where((d) {
            final x = d.data();
            final stock = (x['stock'] as num?)?.toInt() ?? 0;
            final threshold = (x['lowStockThreshold'] as num?)?.toInt() ?? 5;
            return stock <= threshold;
          }).length;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(child: ListTile(leading: const Icon(Icons.warning_amber_outlined), title: Text('$low low-stock items'), subtitle: const Text('Review before accepting more demand.'))),
              ...docs.map((d) {
                final x = d.data();
                final stock = (x['stock'] as num?)?.toInt() ?? 0;
                return Card(child: ListTile(
                  title: Text('${x['title'] ?? x['name'] ?? 'Untitled product'}'),
                  subtitle: Text('SKU: ${x['sku'] ?? 'Not set'} • Stock: $stock'),
                  trailing: Icon(stock <= ((x['lowStockThreshold'] as num?)?.toInt() ?? 5) ? Icons.warning_amber_rounded : Icons.check_circle_outline),
                ));
              }),
              if (docs.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No catalog inventory is available yet.'))),
            ],
          );
        },
      );

  Widget _fulfillment() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.fulfillmentTasks(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              FilledButton.icon(onPressed: _queueTask, icon: const Icon(Icons.add_task), label: const Text('Queue fulfillment task')),
              const SizedBox(height: 10),
              ...docs.map((d) {
                final x = d.data();
                return Card(child: ListTile(
                  leading: const Icon(Icons.local_shipping_outlined),
                  title: Text('Order ${x['orderId'] ?? 'unknown'}'),
                  subtitle: Text('${x['action'] ?? 'fulfill'} • ${x['priority'] ?? 'normal'}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) => service.updateTaskStatus(d.id, v),
                    itemBuilder: (_) => const [PopupMenuItem(value: 'queued', child: Text('Queued')), PopupMenuItem(value: 'processing', child: Text('Processing')), PopupMenuItem(value: 'completed', child: Text('Completed'))],
                    child: Text('${x['status'] ?? 'queued'}'),
                  ),
                ));
              }),
              if (docs.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No fulfillment tasks yet.'))),
            ],
          );
        },
      );

  Widget _returns() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.returnRequests(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Card(child: ListTile(leading: Icon(Icons.shield_outlined), title: Text('Buyer protection aware'), subtitle: Text('Review returns consistently with the order and payment state.'))),
              ...docs.map((d) {
                final x = d.data();
                return Card(child: ListTile(
                  leading: const Icon(Icons.assignment_return_outlined),
                  title: Text('Return ${d.id.substring(0, 6)}'),
                  subtitle: Text('${x['reason'] ?? 'Reason pending'} • ${x['status'] ?? 'requested'}'),
                ));
              }),
              if (docs.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No return requests.'))),
            ],
          );
        },
      );

  Widget _team() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Merchant team', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Invite staff without sharing the owner account.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _invite, icon: const Icon(Icons.person_add_alt_1_outlined), label: const Text('Invite team member')),
          const SizedBox(height: 12),
          _feature('Owner', 'Full commercial control with backend-enforced permissions.', Icons.admin_panel_settings_outlined),
          _feature('Operations', 'Inventory, fulfillment and customer workflow access.', Icons.settings_suggest_outlined),
          _feature('Support', 'Customer messaging and return triage without financial controls.', Icons.support_agent_outlined),
        ],
      );

  Widget _countCard(String title, Stream<QuerySnapshot<Map<String, dynamic>>> stream, IconData icon) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (_, snap) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon), const SizedBox(height: 8), Text('${snap.data?.docs.length ?? 0}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), Text(title)]))),
      );

  Widget _metricText(String title, String value, IconData icon) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), Text(title)])));

  Widget _feature(String title, String subtitle, IconData icon) => Card(child: ListTile(leading: const Icon(Icons.circle, size: 10, color: Color(0xFF38D9A9)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle)));

  Future<void> _queueTask() async {
    final order = TextEditingController();
    final saved = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Queue fulfillment'), content: TextField(controller: order, decoration: const InputDecoration(labelText: 'Order ID')), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Queue'))]));
    if (saved == true) {
      await service.createFulfillmentTask(orderId: order.text, action: 'pack_and_dispatch', priority: 'normal');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fulfillment task queued.')));
    }
    order.dispose();
  }

  Future<void> _invite() async {
    final email = TextEditingController();
    var role = 'operations';
    final saved = await showDialog<bool>(context: context, builder: (_) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(title: const Text('Invite team member'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')), const SizedBox(height: 10), DropdownButtonFormField<String>(initialValue: role, items: const [DropdownMenuItem(value: 'operations', child: Text('Operations')), DropdownMenuItem(value: 'support', child: Text('Support')), DropdownMenuItem(value: 'manager', child: Text('Manager'))], onChanged: (v) => setLocal(() => role = v ?? role), decoration: const InputDecoration(labelText: 'Role'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send invite'))])));
    if (saved == true) {
      await service.submitTeamInvite(email: email.text, role: role);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team invite created.')));
    }
    email.dispose();
  }
}
