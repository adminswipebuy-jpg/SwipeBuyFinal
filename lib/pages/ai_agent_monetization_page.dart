import 'package:flutter/material.dart';
import '../services/ai_agent_monetization_service.dart';

class AiAgentMonetizationPage extends StatefulWidget {
  const AiAgentMonetizationPage({super.key});
  @override
  State<AiAgentMonetizationPage> createState() => _AiAgentMonetizationPageState();
}

class _AiAgentMonetizationPageState extends State<AiAgentMonetizationPage> {
  final service = AiAgentMonetizationService();
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Agent Economy 2.0')),
      body: IndexedStack(index: tab, children: [_buyer(), _creator()]),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Purchases'),
        NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Creator earnings'),
      ]),
    );
  }

  Widget _buyer() => ListView(padding: const EdgeInsets.all(16), children: [
    _hero('Premium AI agents', 'Creators can publish free or paid agents. Purchases should be completed by a trusted payment backend; this screen only creates a purchase request.'),
    const SizedBox(height: 14),
    const Card(child: ListTile(leading: Icon(Icons.lock_outline), title: Text('Payment protection'), subtitle: Text('Payment success must be verified on the trusted backend before an agent is unlocked.'))),
    const SizedBox(height: 12),
    StreamBuilder(stream: service.streamMyAgentPurchases(), builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
      final docs = snap.data?.docs ?? const [];
      if (docs.isEmpty) return const Card(child: ListTile(title: Text('No agent purchases yet'), subtitle: Text('Paid agents you buy will appear here.')));
      return Column(children: docs.map((d) {
        final m = d.data();
        return Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.smart_toy_outlined)), title: Text('Agent ${m['agentId'] ?? ''}'), subtitle: Text('${m['amount'] ?? 0} ${m['currency'] ?? ''} • ${m['status'] ?? 'pending'}')));
      }).toList());
    }),
    const SizedBox(height: 12),
    FilledButton.icon(onPressed: _showPurchaseDialog, icon: const Icon(Icons.add_shopping_cart), label: const Text('Create purchase request')),
  ]);

  Widget _creator() => ListView(padding: const EdgeInsets.all(16), children: [
    _hero('Creator earnings', 'Paid-agent earnings are ledger-driven. Request payouts only from balances confirmed by the trusted backend.'),
    const SizedBox(height: 14),
    StreamBuilder(stream: service.streamMyAgentEarnings(), builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
      final docs = snap.data?.docs ?? const [];
      double total = 0;
      for (final d in docs) {
        total += (d.data()['netAmount'] as num?)?.toDouble() ?? 0;
      }
      return Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Net earnings', style: TextStyle(color: Colors.white60)), const SizedBox(height: 5),
        Text('GH₵ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6), Text('${docs.length} ledger entries', style: const TextStyle(color: Colors.white54)),
      ])));
    }),
    const SizedBox(height: 12),
    const Card(child: ListTile(leading: Icon(Icons.percent), title: Text('Platform fee'), subtitle: Text('Fee percentage and settlement schedule must be configured server-side before production.'))),
    const SizedBox(height: 12),
    FilledButton.icon(onPressed: _showPayoutDialog, icon: const Icon(Icons.payments_outlined), label: const Text('Request payout')),
  ]);

  Widget _hero(String title, String text) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10), gradient: const LinearGradient(colors: [Color(0xFF1A2E26), Color(0xFF111720)])), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(text, style: const TextStyle(color: Colors.white70, height: 1.4))]));

  Future<void> _showPurchaseDialog() async {
    final agent = TextEditingController(); final amount = TextEditingController(text: '10');
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Purchase request'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: agent, decoration: const InputDecoration(labelText: 'Agent ID')), TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (GH₵)'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continue'))]));
    if (ok != true || agent.text.trim().isEmpty) return;
    try { await service.createPurchaseRequest(agentId: agent.text.trim(), amount: double.tryParse(amount.text) ?? 0, currency: 'GHS'); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase request created. Complete payment through the trusted payment flow.'))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  Future<void> _showPayoutDialog() async {
    final amount = TextEditingController(text: '50'); String method = 'Mobile Money';
    final ok = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(title: const Text('Payout request'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (GH₵)')), const SizedBox(height: 10), DropdownButtonFormField<String>(initialValue: method, items: const ['Mobile Money', 'Bank transfer'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setLocal(() => method = v ?? method), decoration: const InputDecoration(labelText: 'Method'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit'))])));
    if (ok != true) return;
    try { await service.submitPayoutRequest(amount: double.tryParse(amount.text) ?? 0, method: method); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payout request submitted for backend review.'))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }
}
