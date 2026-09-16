import 'package:flutter/material.dart';
import '../services/professional_payment_dispute_service.dart';

class ProfessionalPaymentsDisputesPage extends StatefulWidget {
  const ProfessionalPaymentsDisputesPage({super.key, this.bookingId = ''});
  final String bookingId;
  @override
  State<ProfessionalPaymentsDisputesPage> createState() => _ProfessionalPaymentsDisputesPageState();
}

class _ProfessionalPaymentsDisputesPageState extends State<ProfessionalPaymentsDisputesPage> {
  final service = ProfessionalPaymentDisputeService();
  final amount = TextEditingController();
  final booking = TextEditingController();
  final provider = TextEditingController();
  final currency = TextEditingController(text: 'GHS');

  @override
  void initState() { super.initState(); booking.text = widget.bookingId; }
  @override
  void dispose() { amount.dispose(); booking.dispose(); provider.dispose(); currency.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professional Payments & Disputes 2.0')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Secure contract payments', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('Payment, escrow, payout and dispute decisions should be verified by trusted backend systems.', style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          TextField(controller: booking, decoration: const InputDecoration(labelText: 'Booking ID')),
          const SizedBox(height: 10),
          TextField(controller: provider, decoration: const InputDecoration(labelText: 'Professional name')),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: TextField(controller: amount, decoration: const InputDecoration(labelText: 'Escrow amount'))), const SizedBox(width: 10), SizedBox(width: 88, child: TextField(controller: currency, decoration: const InputDecoration(labelText: 'Currency')))]),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _fund, icon: const Icon(Icons.lock_outline), label: const Text('Request secure escrow'))),
        ]))),
        const SizedBox(height: 14),
        Card(child: Column(children: [
          const ListTile(leading: Icon(Icons.account_balance_wallet_outlined), title: Text('Escrow & payout safeguards'), subtitle: Text('Funds should remain provider-controlled until backend contract milestones are verified.')),
          ListTile(leading: const Icon(Icons.gavel_outlined), title: const Text('Open a dispute'), subtitle: const Text('Start a buyer-side dispute without directly changing payment balances.'), onTap: _dispute),
          ListTile(leading: const Icon(Icons.check_circle_outline), title: const Text('Request payout release'), subtitle: const Text('Ask the backend to evaluate milestone completion before release.'), onTap: _release),
        ])),
        const SizedBox(height: 14),
        const Text('My financial requests', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        StreamBuilder<List<Map<String, dynamic>>>(stream: service.streamMyRequests(), builder: (context, snap) {
          final rows = snap.data ?? const <Map<String, dynamic>>[];
          if (rows.isEmpty) return const Text('No financial requests yet.', style: TextStyle(color: Colors.white60));
          return Column(children: rows.map((r) => Card(child: ListTile(leading: const Icon(Icons.receipt_long_outlined), title: Text((r['kind'] ?? 'request').toString().replaceAll('_', ' ')), subtitle: Text('${r['providerName'] ?? 'Professional'} • ${r['amount'] ?? ''} ${r['currency'] ?? ''}'), trailing: Text((r['status'] ?? 'pending').toString())))).toList());
        }),
      ]),
    );
  }

  Future<void> _fund() async {
    if (booking.text.trim().isEmpty || amount.text.trim().isEmpty) return;
    await service.createEscrowRequest(bookingId: booking.text.trim(), providerName: provider.text.trim(), amount: amount.text.trim(), currency: currency.text.trim());
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escrow request submitted for backend confirmation.')));
  }
  Future<void> _release() async {
    if (booking.text.trim().isEmpty) return;
    await service.requestPayoutRelease(bookingId: booking.text.trim());
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payout release requested.')));
  }
  Future<void> _dispute() async {
    if (booking.text.trim().isEmpty) return;
    final detail = TextEditingController();
    var reason = 'Work quality';
    await showDialog<void>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) => AlertDialog(
      title: const Text('Open dispute'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButtonFormField<String>(initialValue: reason, items: const ['Work quality', 'Missed milestone', 'No-show', 'Fraud concern', 'Other'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setLocal(() => reason = v ?? reason)), const SizedBox(height: 10), TextField(controller: detail, maxLines: 4, decoration: const InputDecoration(labelText: 'Details'))]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), FilledButton(onPressed: () async { await service.openDispute(bookingId: booking.text.trim(), reason: reason, details: detail.text); if (ctx.mounted) Navigator.pop(ctx); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dispute opened for review.'))); }, child: const Text('Submit'))],
    )));
    detail.dispose();
  }
}
