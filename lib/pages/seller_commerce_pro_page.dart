import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SellerCommerceProPage extends StatefulWidget {
  const SellerCommerceProPage({super.key});
  @override
  State<SellerCommerceProPage> createState() => _SellerCommerceProPageState();
}

class _SellerCommerceProPageState extends State<SellerCommerceProPage> {
  int tab = 0;

  CollectionReference<Map<String, dynamic>> get listings =>
      FirebaseFirestore.instance.collection('listings');

  CollectionReference<Map<String, dynamic>> get orders =>
      FirebaseFirestore.instance.collection('orders');

  String get uid => AuthService.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> _owned(String field) {
    if (uid.isEmpty) return const Stream.empty();
    return FirebaseFirestore.instance.collection(field).where('ownerId', isEqualTo: uid).limit(100).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_storefront(), _products(), _orders(), _customers(), _growth()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Commerce Pro'),
        actions: [
          IconButton(onPressed: () => _showComingSoon('Storefront preview'), icon: const Icon(Icons.preview_outlined)),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Store'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Customers'),
          NavigationDestination(icon: Icon(Icons.trending_up_outlined), label: 'Growth'),
        ],
      ),
    );
  }

  Widget _storefront() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Your storefront', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Sell products, services and experiences with one professional dashboard.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _metric('Products', _owned('listings'))),
            const SizedBox(width: 10),
            Expanded(child: _metric('Orders', _owned('orders'))),
          ]),
          const SizedBox(height: 10),
          Card(
            child: Column(children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.verified_outlined)),
                title: Text(AuthService.currentUser?.displayName ?? 'Your Store'),
                subtitle: const Text('Professional seller profile'),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Expanded(child: FilledButton.icon(onPressed: _showComingSoon, icon: const Icon(Icons.add), label: const Text('Add Product'))),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton.icon(onPressed: () => setState(() => tab = 4), icon: const Icon(Icons.bar_chart), label: const Text('Growth'))),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          _feature('Storefront customization', 'Brand image, bio, hours, location, delivery zones and featured collections.', Icons.palette_outlined),
          _feature('Smart discounts', 'Create coupon codes, limited-time offers and bundles.', Icons.local_offer_outlined),
          _feature('Delivery controls', 'Choose delivery, pickup or customer-arranged fulfilment.', Icons.local_shipping_outlined),
          _feature('Reputation', 'Collect reviews, display ratings and highlight verified seller status.', Icons.star_border),
        ],
      );

  Widget _products() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _owned('listings'),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              FilledButton.icon(onPressed: _showComingSoon, icon: const Icon(Icons.add), label: const Text('Create Product')),
              const SizedBox(height: 8),
              ...docs.map((d) {
                final x = d.data();
                return Card(child: ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: Text('${x['title'] ?? 'Untitled'}'),
                  subtitle: Text('${x['category'] ?? 'Product'} • ${x['location'] ?? ''}'),
                  trailing: Text('${x['price'] ?? ''}'),
                ));
              }),
              if (docs.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No products yet. Create your first product.'))),
            ],
          );
        },
      );

  Widget _orders() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _owned('orders'),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ...docs.map((d) {
                final x = d.data();
                return Card(child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text('Order ${d.id.substring(0, 6)}'),
                  subtitle: Text('${x['status'] ?? 'pending'} • ${x['paymentStatus'] ?? 'unpaid'}'),
                  trailing: const Icon(Icons.chevron_right),
                ));
              }),
              if (docs.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No seller orders yet.'))),
            ],
          );
        },
      );

  Widget _customers() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Customer relationships', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _feature('Customer profiles', 'Keep a future-ready customer directory linked to verified transactions.', Icons.person_search_outlined),
          _feature('Reviews & reputation', 'Turn completed orders into ratings and trust signals.', Icons.reviews_outlined),
          _feature('Customer messaging', 'Move customers directly into the existing SwipeBuy chat system.', Icons.chat_bubble_outline),
          _feature('Repeat buyers', 'Foundation for loyalty rewards and personalized offers.', Icons.repeat_outlined),
        ],
      );

  Widget _growth() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Growth center', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          _growthCard('Views', 'Connect to V6.4 analytics', Icons.visibility_outlined),
          _growthCard('Conversion', 'Product views → orders', Icons.track_changes_outlined),
          _growthCard('Promotions', 'Connect to V5.2 advertising', Icons.campaign_outlined),
          _growthCard('Revenue', 'Connect to V5.1 wallet and ledger', Icons.payments_outlined),
          _growthCard('AI Insights', 'Use SwipeBuy AI to identify growth opportunities', Icons.auto_awesome_outlined),
        ],
      );

  Widget _metric(String title, Stream<QuerySnapshot<Map<String, dynamic>>> stream) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (_, snap) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${snap.data?.docs.length ?? 0}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              Text(title),
            ]),
          ),
        ),
      );

  Widget _feature(String title, String subtitle, IconData icon) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(leading: Icon(icon, color: const Color(0xFF38D9A9)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle)),
      );

  Widget _growthCard(String title, String subtitle, IconData icon) => Card(
        child: ListTile(leading: Icon(icon, color: const Color(0xFFFF7A18)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right)),
      );

  void _showComingSoon([String label = 'This feature']) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label is wired for the next backend step.')));
  }
}
