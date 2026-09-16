import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/creator_events_commerce_service.dart';

class CreatorEventsCommercePage extends StatefulWidget {
  const CreatorEventsCommercePage({super.key});
  @override State<CreatorEventsCommercePage> createState() => _CreatorEventsCommercePageState();
}

class _CreatorEventsCommercePageState extends State<CreatorEventsCommercePage> with SingleTickerProviderStateMixin {
  late final TabController tabs = TabController(length: 3, vsync: this);
  final service = CreatorEventsCommerceService();
  @override void dispose() { tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Creator Events & Fan Commerce 2.0', style: TextStyle(fontWeight: FontWeight.w900)),
      bottom: TabBar(controller: tabs, tabs: const [Tab(text: 'Events'), Tab(text: 'Tickets'), Tab(text: 'Fan Shop')]),
    ),
    body: TabBarView(controller: tabs, children: [_events(), _tickets(), _fanShop()]),
  );

  Widget _events() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: service.publishedEvents(),
    builder: (_, snap) {
      if (snap.hasError) return const Center(child: Text('Unable to load creator events right now.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return const _Empty(icon: Icons.event_outlined, title: 'No creator events yet', subtitle: 'Published creator events will appear here.');
      return ListView.separated(
        padding: const EdgeInsets.all(16), itemCount: docs.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final d = docs[i].data(); final id = docs[i].id;
          final price = d['priceLabel']?.toString() ?? 'Price shown at checkout';
          return Card(color: const Color(0xFF111720), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const CircleAvatar(child: Icon(Icons.celebration_outlined)), const SizedBox(width: 10), Expanded(child: Text(d['title']?.toString() ?? 'Creator event', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))), Text(price, style: const TextStyle(fontWeight: FontWeight.w800))]),
            const SizedBox(height: 6), Text('${d['creatorName'] ?? 'Creator'} • ${d['format'] ?? 'Online'} • ${d['category'] ?? 'Community'}', style: const TextStyle(color: Colors.white60)),
            if ((d['description']?.toString() ?? '').isNotEmpty) ...[const SizedBox(height: 6), Text(d['description'].toString(), maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54))],
            const SizedBox(height: 10), Row(children: [const Icon(Icons.schedule, size: 16, color: Colors.white54), const SizedBox(width: 6), Text(d['startLabel']?.toString() ?? 'Start time set by creator', style: const TextStyle(color: Colors.white54)), const Spacer(), FilledButton(onPressed: () => _buyTicket(id), child: const Text('Get ticket'))])
          ])));
        },
      );
    },
  );

  Widget _tickets() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: service.myTickets(),
    builder: (_, snap) {
      if (snap.hasError) return const Center(child: Text('Unable to load your tickets.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return const _Empty(icon: Icons.confirmation_number_outlined, title: 'No tickets yet', subtitle: 'Your verified creator-event tickets will appear here.');
      return ListView.separated(padding: const EdgeInsets.all(16), itemCount: docs.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) {
        final d = docs[i].data();
        return Card(color: const Color(0xFF111720), child: ListTile(leading: const CircleAvatar(child: Icon(Icons.qr_code_2)), title: Text(d['eventTitle']?.toString() ?? 'Creator event', style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('${d['ticketType'] ?? 'General'} • ${d['status'] ?? 'pending'}'), trailing: const Icon(Icons.chevron_right)));
      });
    },
  );

  Widget _fanShop() => ListView(padding: const EdgeInsets.all(18), children: [
    const Text('Creator Fan Shop', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
    const SizedBox(height: 8),
    const Text('Commerce around creator events: merch, bundles and limited fan drops. Prices, stock, payments and fulfillment are verified server-side.', style: TextStyle(color: Colors.white54)),
    const SizedBox(height: 18),
    _ShopCard(icon: Icons.checkroom_outlined, title: 'Event Merch', subtitle: 'Request official merchandise linked to a creator event.'),
    _ShopCard(icon: Icons.card_giftcard_outlined, title: 'Fan Bundle', subtitle: 'Combine event access with premium creator perks.'),
    _ShopCard(icon: Icons.local_activity_outlined, title: 'Limited Drop', subtitle: 'Request a limited fan collectible or creator drop.'),
  ]);

  Future<void> _buyTicket(String eventId) async {
    int quantity = 1; String type = 'General';
    await showDialog(context: context, builder: (context) => StatefulBuilder(builder: (_, setModal) => AlertDialog(
      title: const Text('Reserve creator-event ticket'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(initialValue: type, items: const ['General','VIP','Fan Pass'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setModal(() => type = v ?? type)),
        const SizedBox(height: 10), Row(children: [const Text('Quantity'), const Spacer(), IconButton(onPressed: quantity <= 1 ? null : () => setModal(() => quantity--), icon: const Icon(Icons.remove)), Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w900)), IconButton(onPressed: () => setModal(() => quantity++), icon: const Icon(Icons.add))]),
        const SizedBox(height: 8), const Text('Payment and ticket issuance happen only after trusted backend verification.', style: TextStyle(color: Colors.white54)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async { await service.requestTicket(eventId: eventId, ticketType: type, quantity: quantity); if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket request saved for secure checkout.'))); } }, child: const Text('Continue'))],
    )));
  }
}

class _ShopCard extends StatelessWidget {
  final IconData icon; final String title, subtitle;
  const _ShopCard({required this.icon, required this.title, required this.subtitle});
  @override Widget build(BuildContext context) => Card(color: const Color(0xFF111720), child: ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Secure fan-commerce flow will open after creator item selection.')))));
}
class _Empty extends StatelessWidget { final IconData icon; final String title, subtitle; const _Empty({required this.icon, required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 58, color: Colors.white30), const SizedBox(height: 14), Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54))]))); }
