import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/wallet_service.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final wallet = WalletService();

  Future<void> _requestDeposit() async {
    final controller = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add money'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (GHS)', prefixText: 'GHS '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, double.tryParse(controller.text)), child: const Text('Continue')),
        ],
      ),
    );
    if (amount == null || amount <= 0) return;
    await wallet.requestDeposit(amount: amount, provider: 'mobile_money');
    if (mounted) _snack('Deposit request created. Payment confirmation will come from the provider.');
  }

  Future<void> _requestWithdrawal() async {
    final controller = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Withdraw'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (GHS)', prefixText: 'GHS '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, double.tryParse(controller.text)), child: const Text('Request')),
        ],
      ),
    );
    if (amount == null || amount <= 0) return;
    await wallet.requestWithdrawal(amount: amount, method: 'mobile_money');
    if (mounted) _snack('Withdrawal request submitted for review.');
  }

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SwipeBuy Wallet')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: wallet.watchWallet(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? const <String, dynamic>{};
          final balance = (data['availableBalance'] ?? 0).toDouble();
          final pending = (data['pendingBalance'] ?? 0).toDouble();
          final currency = (data['currency'] ?? 'GHS') as String;
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(colors: [Color(0xFF0F5132), Color(0xFF0D2B23)]),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Available balance', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text('$currency ${balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('Pending: $currency ${pending.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white60)),
                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(child: FilledButton.icon(onPressed: _requestDeposit, icon: const Icon(Icons.add), label: const Text('Add money'))),
                    const SizedBox(width: 10),
                    Expanded(child: OutlinedButton.icon(onPressed: _requestWithdrawal, icon: const Icon(Icons.arrow_outward), label: const Text('Withdraw'))),
                  ]),
                ]),
              ),
              const SizedBox(height: 20),
              const Text('How SwipeBuy Wallet works', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Payments are confirmed by trusted payment providers and backend services. The mobile app never marks money as successfully received on its own.', style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 22),
              const Text('Recent transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: wallet.watchTransactions(),
                builder: (context, txSnap) {
                  if (!txSnap.hasData || txSnap.data!.docs.isEmpty) {
                    return const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No transactions yet.')));
                  }
                  return Column(children: txSnap.data!.docs.map((doc) {
                    final d = doc.data();
                    final amount = (d['amount'] ?? 0).toDouble();
                    final type = (d['type'] ?? 'transaction') as String;
                    final status = (d['status'] ?? 'pending') as String;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Icon(type == 'credit' ? Icons.arrow_downward : Icons.arrow_upward)),
                        title: Text(d['description'] ?? type),
                        subtitle: Text(status),
                        trailing: Text('${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    );
                  }).toList());
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
