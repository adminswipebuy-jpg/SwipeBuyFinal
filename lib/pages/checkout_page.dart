import 'package:flutter/material.dart';
import '../services/checkout_service.dart';
import 'buyer_protection_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.product});
  final Map<String, String> product;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _address = TextEditingController();
  final _coupon = TextEditingController();
  String _delivery = 'Home delivery';
  bool _busy = false;

  @override
  void dispose() { _address.dispose(); _coupon.dispose(); super.dispose(); }

  Future<void> _continueToPayment() async {
    if (_address.text.trim().isEmpty && _delivery == 'Home delivery') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a delivery address first.')));
      return;
    }
    setState(() => _busy = true);
    try {
      final id = await CheckoutService().createCheckoutRequest(
        productId: widget.product['title']!, businessId: widget.product['seller']!,
        title: widget.product['title']!, amountText: widget.product['price']!,
        deliveryMethod: _delivery, deliveryAddress: _address.text, couponCode: _coupon.text,
      );
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (_) => AlertDialog(
        title: const Text('Checkout request created'),
        content: Text('Reference: $id\n\nThe next step is trusted payment-provider confirmation. This app does not mark the order as paid from the phone.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Checkout', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.shopping_bag_outlined)), title: Text(p['title']!, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(p['seller']!), trailing: Text(p['price']!, style: const TextStyle(fontWeight: FontWeight.w900)))),
        const SizedBox(height: 14),
        const Text('Delivery', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        SegmentedButton<String>(segments: const [ButtonSegment(value: 'Home delivery', label: Text('Delivery'), icon: Icon(Icons.local_shipping_outlined)), ButtonSegment(value: 'Pickup', label: Text('Pickup'), icon: Icon(Icons.store_outlined))], selected: {_delivery}, onSelectionChanged: (s) => setState(() => _delivery = s.first)),
        if (_delivery == 'Home delivery') ...[
          const SizedBox(height: 10),
          TextField(controller: _address, maxLines: 3, decoration: const InputDecoration(labelText: 'Delivery address', hintText: 'Area, street, landmark', border: OutlineInputBorder())),
        ],
        const SizedBox(height: 18),
        const Text('Coupon', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        TextField(controller: _coupon, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(prefixIcon: Icon(Icons.local_offer_outlined), labelText: 'Coupon code', border: OutlineInputBorder())),
        const SizedBox(height: 18),
        Card(child: Column(children: [
          const ListTile(leading: Icon(Icons.verified_user_outlined), title: Text('Buyer Protection', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('Order tracking, returns and dispute support')), 
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerProtectionPage())), child: const Text('Learn how it works')),
        ])),
        const SizedBox(height: 18),
        SizedBox(height: 54, child: FilledButton.icon(onPressed: _busy ? null : _continueToPayment, icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.lock_outline), label: Text(_busy ? 'Creating checkout…' : 'Continue to payment'))),
      ]),
    );
  }
}
