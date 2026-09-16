import 'package:flutter/material.dart';
import '../services/checkout_cart_service.dart';

class CartCheckoutPage extends StatefulWidget {
  final List<CartItem> items;
  const CartCheckoutPage({super.key, required this.items});

  @override
  State<CartCheckoutPage> createState() => _CartCheckoutPageState();
}

class _CartCheckoutPageState extends State<CartCheckoutPage> {
  final address = TextEditingController();
  String method = 'delivery';
  bool submitting = false;

  int get total => widget.items.fold<int>(0, (sum, item) => sum + item.subtotal);

  @override
  void dispose() {
    address.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (address.text.trim().isEmpty || widget.items.isEmpty) return;
    setState(() => submitting = true);
    try {
      await CheckoutCartService().createOrderFromCart(
        items: widget.items,
        currency: widget.items.first.currency,
        deliveryAddress: address.text,
        deliveryMethod: method,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created. Continue to secure payment.')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...widget.items.map((item) => ListTile(
            title: Text(item.title),
            subtitle: Text('${item.quantity} × ${item.unitAmount} ${item.currency}'),
            trailing: Text('${item.subtotal} ${item.currency}'),
          )),
          const Divider(),
          Text('Subtotal: $total ${widget.items.first.currency}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: method,
            decoration: const InputDecoration(labelText: 'Fulfilment'),
            items: const [
              DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
              DropdownMenuItem(value: 'pickup', child: Text('Pickup')),
            ],
            onChanged: (v) => setState(() => method = v ?? 'delivery'),
          ),
          if (method == 'delivery') ...[
            const SizedBox(height: 12),
            TextField(
              controller: address,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Delivery address',
                hintText: 'Enter your delivery location',
                filled: true,
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: submitting ? null : submit,
            icon: const Icon(Icons.lock_outline),
            label: Text(submitting ? 'Creating...' : 'Place Order'),
          ),
        ],
      ),
    );
  }
}
