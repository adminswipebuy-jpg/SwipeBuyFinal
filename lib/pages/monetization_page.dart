import 'package:flutter/material.dart';
import '../services/monetization_service.dart';

class MonetizationPage extends StatefulWidget {
  const MonetizationPage({super.key});
  @override
  State<MonetizationPage> createState() => _MonetizationPageState();
}

class _MonetizationPageState extends State<MonetizationPage> {
  final service = MonetizationService();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SwipeBuy Monetization')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Turn attention into opportunity', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('Creator earnings, subscriptions, tips, promotions and business advertising.', style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _summary('Available', 'GHS 0.00', Icons.account_balance_wallet_outlined)),
          const SizedBox(width: 10),
          Expanded(child: _summary('This month', 'GHS 0.00', Icons.trending_up)),
        ]),
        const SizedBox(height: 12),
        Card(
          color: const Color(0xFF111720),
          child: Column(children: [
            ListTile(leading: const Icon(Icons.card_giftcard), title: const Text('Tips & LIVE gifts'), subtitle: const Text('Let fans support your work.'), trailing: const Icon(Icons.chevron_right), onTap: () => _snack('Tips and gifts are ready for trusted payment integration.')),
            ListTile(leading: const Icon(Icons.workspace_premium), title: const Text('Creator subscriptions'), subtitle: const Text('Offer members-only content and perks.'), trailing: const Icon(Icons.chevron_right), onTap: () => _snack('Subscription plans can be configured next.')),
            ListTile(leading: const Icon(Icons.campaign_outlined), title: const Text('Promote a post'), subtitle: const Text('Create an advertising campaign draft.'), trailing: const Icon(Icons.chevron_right), onTap: _campaignDialog),
          ]),
        ),
        const SizedBox(height: 12),
        Card(
          color: const Color(0xFF111720),
          child: Column(children: [
            ListTile(leading: const Icon(Icons.payments_outlined), title: const Text('Request payout'), subtitle: const Text('Payouts are reviewed and completed by the trusted backend.'), trailing: const Icon(Icons.chevron_right), onTap: _payoutDialog),
            ListTile(leading: const Icon(Icons.analytics_outlined), title: const Text('Revenue analytics'), subtitle: const Text('Track content, commerce and campaign performance.'), trailing: const Icon(Icons.chevron_right), onTap: () => _snack('Analytics dashboard foundation is ready.')),
          ]),
        ),
        const SizedBox(height: 18),
        const Text('Recent earnings events', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        StreamBuilder(
          stream: service.creatorEarnings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No earnings have been recorded yet.')));
            return Column(children: docs.take(10).map((d) {
              final data = d.data();
              return Card(child: ListTile(leading: const Icon(Icons.monetization_on_outlined), title: Text(data['type']?.toString() ?? 'Earning'), subtitle: Text(data['createdAt']?.toString() ?? 'Pending'), trailing: Text('GHS ${data['amount'] ?? '0'}', style: const TextStyle(fontWeight: FontWeight.bold))));
            }).toList());
          },
        ),
      ],
    ),
  );

  Widget _summary(String label, String value, IconData icon) => Card(
    color: const Color(0xFF12382E),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: const Color(0xFF38D9A9)),
        const SizedBox(height: 14),
        Text(label, style: const TextStyle(color: Colors.white60)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      ]),
    ),
  );

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _campaignDialog() async {
    final name = TextEditingController();
    final budget = TextEditingController(text: '50');
    String objective = 'Reach';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
        title: const Text('Create promotion draft'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Campaign name')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(initialValue: objective, items: const ['Reach', 'Engagement', 'Traffic', 'Sales'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setLocal(() => objective = v ?? objective), decoration: const InputDecoration(labelText: 'Objective')),
          const SizedBox(height: 12),
          TextField(controller: budget, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Daily budget (GHS)')),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save draft'))],
      )),
    );
    if (ok != true) return;
    try {
      final id = await service.createCampaignDraft(name: name.text, objective: objective, dailyBudget: double.tryParse(budget.text) ?? 0);
      if (mounted) _snack('Campaign draft created: $id');
    } catch (e) { if (mounted) _snack(e.toString()); }
  }

  Future<void> _payoutDialog() async {
    final amount = TextEditingController(text: '50');
    String method = 'Bank / Mobile Money';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
        title: const Text('Request payout'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (GHS)')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(initialValue: method, items: const ['Bank / Mobile Money', 'PayPal'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setLocal(() => method = v ?? method), decoration: const InputDecoration(labelText: 'Payout method')),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Request'))],
      )),
    );
    if (ok != true) return;
    try {
      final id = await service.requestPayout(amount: double.tryParse(amount.text) ?? 0, method: method);
      if (mounted) _snack('Payout request submitted: $id');
    } catch (e) { if (mounted) _snack(e.toString()); }
  }
}
