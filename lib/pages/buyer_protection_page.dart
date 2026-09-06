import 'package:flutter/material.dart';

class BuyerProtectionPage extends StatelessWidget {
  const BuyerProtectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Protection')),
      body: ListView(padding: const EdgeInsets.all(18), children: const [
        Text('Shop with confidence', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        SizedBox(height: 8),
        Text('SwipeBuy is designed to keep the checkout, delivery and dispute journey clear and traceable.'),
        SizedBox(height: 22),
        _ProtectionCard(Icons.lock_outline, 'Secure checkout', 'Payment confirmation should be handled by trusted payment infrastructure before an order is marked paid.'),
        _ProtectionCard(Icons.receipt_long_outlined, 'Order records', 'Your checkout and order states are recorded so support can investigate problems.'),
        _ProtectionCard(Icons.assignment_return_outlined, 'Returns & disputes', 'Request a return for eligible orders and provide a reason and supporting details.'),
        _ProtectionCard(Icons.storefront_outlined, 'Seller accountability', 'Seller reputation, reviews and order history help buyers make informed decisions.'),
        _ProtectionCard(Icons.support_agent_outlined, 'Support escalation', 'When a transaction needs human review, keep the order ID and evidence ready.'),
      ]),
    );
  }
}

class _ProtectionCard extends StatelessWidget {
  const _ProtectionCard(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 28), const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 5), Text(body, style: const TextStyle(color: Colors.white60, height: 1.3)),
      ])),
    ])),
  );
}
