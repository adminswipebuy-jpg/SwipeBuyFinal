import 'package:flutter/material.dart';
import '../services/marketplace_v2_service.dart';
import 'checkout_page.dart';
import 'buyer_protection_page.dart';

class MarketplaceV2Page extends StatefulWidget {
  const MarketplaceV2Page({super.key});

  @override
  State<MarketplaceV2Page> createState() => _MarketplaceV2PageState();
}

class _MarketplaceV2PageState extends State<MarketplaceV2Page> {
  final service = MarketplaceV2Service();
  String tab = 'Discover';
  final List<Map<String, String>> demo = const [
    {'title': 'Premium Smartphone', 'price': 'GHS 4,500', 'seller': 'Verified Electronics'},
    {'title': 'Wireless Headphones', 'price': 'GHS 850', 'seller': 'Tech Hub Ghana'},
    {'title': 'Everyday Sneakers', 'price': 'GHS 620', 'seller': 'Style House'},
    {'title': 'Smart Fitness Watch', 'price': 'GHS 1,250', 'seller': 'Active Gear'},
  ];

  Future<void> _compare(Map<String, String> p) async {
    try {
      await service.addToComparison(productId: p['title']!, businessId: p['seller']!, title: p['title']!, price: p['price']!);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to comparison')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace 2.0', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () => setState(() => tab = 'Wishlist')),
          IconButton(icon: const Icon(Icons.compare_arrows), onPressed: () => setState(() => tab = 'Compare')),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(children: [
              for (final item in const ['Discover', 'Deals', 'Wishlist', 'Compare', 'Orders', 'Returns']) ...[
                ChoiceChip(label: Text(item), selected: tab == item, onSelected: (_) => setState(() => tab = item)),
                const SizedBox(width: 8),
              ],
            ]),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (tab == 'Wishlist') return _wishlist();
    if (tab == 'Compare') return _compareView();
    if (tab == 'Returns') return _returns();
    if (tab == 'Orders') return _orders();
    return _discover();
  }

  Widget _discover() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerProtectionPage())), child: _banner('Buyer Protection', 'Secure checkout, dispute support and transparent seller reputation.', Icons.verified_user_outlined)),
        const SizedBox(height: 12),
        _banner('Today’s Deals', 'Limited-time coupons and price drops from verified sellers.', Icons.local_offer_outlined),
        const SizedBox(height: 16),
        const Text('Recommended for you', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: demo.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: .74),
          itemBuilder: (_, i) {
            final p = demo[i];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Container(decoration: BoxDecoration(color: Colors.white.withValues(alpha: .04), borderRadius: BorderRadius.circular(14)), child: const Center(child: Icon(Icons.shopping_bag_outlined, size: 48)))),
                  const SizedBox(height: 8),
                  Text(p['title']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(p['price']!, style: const TextStyle(fontWeight: FontWeight.w900)),
                  Text(p['seller']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 7),
                  Row(children: [
                    IconButton(tooltip: 'Save', icon: const Icon(Icons.favorite_border, size: 19), onPressed: () async { try { await service.setWishlist(productId: p['title']!, businessId: p['seller']!, title: p['title']!, price: p['price']!); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to wishlist'))); } catch (_) {} }),
                    IconButton(tooltip: 'Compare', icon: const Icon(Icons.compare_arrows, size: 19), onPressed: () => _compare(p)),
                    Expanded(child: FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutPage(product: p))), child: const Text('Buy'))),
                  ]),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _wishlist() => StreamBuilder(
    stream: service.wishlistStream(),
    builder: (_, snap) {
      if (snap.hasError) return const Center(child: Text('Unable to load wishlist.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return const Center(child: Text('Your wishlist is empty.'));
      return ListView.builder(
        padding: const EdgeInsets.all(14), itemCount: docs.length,
        itemBuilder: (_, i) { final d = docs[i].data(); return Card(child: ListTile(leading: const Icon(Icons.favorite), title: Text(d['title']?.toString() ?? 'Product'), subtitle: Text(d['price']?.toString() ?? ''), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => service.removeWishlist(d['businessId']!.toString(), d['productId']!.toString())))); },
      );
    },
  );

  Widget _compareView() => StreamBuilder(
    stream: service.comparisonStream(),
    builder: (_, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      return Column(children: [
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [const Expanded(child: Text('Compare up to 4 products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), TextButton(onPressed: docs.isEmpty ? null : service.clearComparison, child: const Text('Clear all'))])),
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 14), itemCount: docs.length, itemBuilder: (_, i) { final d = docs[i].data(); return Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [const Icon(Icons.inventory_2_outlined, size: 34), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d['title']?.toString() ?? 'Product', style: const TextStyle(fontWeight: FontWeight.w800)), Text(d['price']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold)), Text(d['businessId']?.toString() ?? '', style: const TextStyle(color: Colors.white60, fontSize: 12))]))]))); }))
      ]);
    },
  );

  Widget _orders() => ListView(padding: const EdgeInsets.all(14), children: [
    _orderCard('SB-10482', 'Delivered', 'GHS 1,250', Icons.check_circle_outline),
    _orderCard('SB-10471', 'In transit', 'GHS 620', Icons.local_shipping_outlined),
    _orderCard('SB-10452', 'Processing', 'GHS 4,500', Icons.hourglass_top_outlined),
  ]);

  Widget _returns() => ListView(padding: const EdgeInsets.all(14), children: [
    _banner('Easy Returns', 'Request a return from an order, select a reason, and follow status updates.', Icons.assignment_return_outlined),
    const SizedBox(height: 12),
    FilledButton.icon(onPressed: () => _returnSheet(), icon: const Icon(Icons.add), label: const Text('Request a return')),
  ]);

  Future<void> _returnSheet() async {
    String reason = 'Wrong item';
    String note = '';
    await showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16), child: StatefulBuilder(builder: (ctx, setSheet) => Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Request a return', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(initialValue: reason, items: const [DropdownMenuItem(value: 'Wrong item', child: Text('Wrong item')), DropdownMenuItem(value: 'Damaged', child: Text('Damaged')), DropdownMenuItem(value: 'Not as described', child: Text('Not as described'))], onChanged: (v) => setSheet(() => reason = v ?? reason)),
      TextField(onChanged: (v) => note = v, decoration: const InputDecoration(labelText: 'Note')),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: () async { try { await service.submitReturn(orderId: 'order_id_here', reason: reason, note: note); if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Return request submitted'))); } } catch (_) {} }, child: const Text('Submit request'))),
    ]))));
  }

  Widget _orderCard(String id, String status, String amount, IconData icon) => Card(child: ListTile(leading: Icon(icon), title: Text(id, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(status), trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.w900))));

  Widget _banner(String title, String subtitle, IconData icon) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFF111822), border: Border.all(color: Colors.white10)), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .06)), child: Icon(icon)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white60, height: 1.2))]))]));
}
