import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/global_services_marketplace_service.dart';
import 'professional_booking_page.dart';
import 'professional_reputation_page.dart';
import 'professional_payments_disputes_page.dart';

class GlobalServicesMarketplacePage extends StatefulWidget {
  const GlobalServicesMarketplacePage({super.key});
  @override
  State<GlobalServicesMarketplacePage> createState() => _GlobalServicesMarketplacePageState();
}

class _GlobalServicesMarketplacePageState extends State<GlobalServicesMarketplacePage> {
  final service = GlobalServicesMarketplaceService();
  String category = 'All';
  String mode = 'For you';
  final categories = const ['All', 'Design', 'Tech', 'Finance', 'Legal', 'Marketing', 'Home', 'Beauty', 'Events'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professional Services Marketplace')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.streamServices(category: category),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Map<String, dynamic>>[];
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _hero(),
                const SizedBox(height: 14),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ChoiceChip(
                      label: Text(categories[i]),
                      selected: category == categories[i],
                      onSelected: (_) => setState(() => category = categories[i]),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'For you', label: Text('For you'), icon: Icon(Icons.auto_awesome)),
                    ButtonSegment(value: 'Nearby', label: Text('Nearby'), icon: Icon(Icons.location_on_outlined)),
                    ButtonSegment(value: 'Top rated', label: Text('Top rated'), icon: Icon(Icons.star_outline)),
                  ],
                  selected: {mode},
                  onSelectionChanged: (v) => setState(() => mode = v.first),
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting && rows.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                else if (rows.isEmpty)
                  _empty()
                else
                  ...rows.map(_card),
                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _offerService,
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Offer a service'),
      ),
    );
  }

  Widget _hero() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(colors: [Color(0xFF10271F), Color(0xFF101722)]),
      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: .18)),
    ),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Hire trusted professionals', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      SizedBox(height: 6),
      Text('Compare skills, reputation, availability and price — all inside SwipeBuy.', style: TextStyle(color: Colors.white70)),
      SizedBox(height: 12),
      Row(children: [Icon(Icons.verified_outlined, color: Color(0xFF10B981)), SizedBox(width: 7), Text('Verification + reviews + secure contracts', style: TextStyle(fontWeight: FontWeight.w800))]),
    ]),
  );

  Widget _card(Map<String, dynamic> row) {
    final title = (row['title'] ?? 'Professional service').toString();
    final provider = (row['providerName'] ?? 'SwipeBuy Professional').toString();
    final cat = (row['category'] ?? 'Services').toString();
    final price = (row['startingPrice'] ?? 'Quote').toString();
    final rating = (row['rating'] ?? 0).toString();
    final location = (row['location'] ?? 'Global').toString();
    final providerId = (row['providerId'] ?? row['id'] ?? '').toString();
    final verified = row['verified'] == true;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(child: Icon(Icons.person_outline)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text(provider, style: const TextStyle(fontWeight: FontWeight.w900))), if (verified) const Icon(Icons.verified, size: 17, color: Color(0xFF10B981))]),
              Text('$cat • $location', style: const TextStyle(color: Colors.white60)),
            ])),
          ]),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('$rating★  •  From $price', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => _requestQuote(row), child: const Text('Request quote'))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton(onPressed: () => _hire(row), child: const Text('Hire'))),
          ]),
          if (providerId.isNotEmpty) ...[
            const SizedBox(height: 6),
            TextButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfessionalReputationPage(providerId: providerId, providerName: provider))), icon: const Icon(Icons.star_outline), label: const Text('View reputation & reviews')),
            TextButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfessionalPaymentsDisputesPage())), icon: const Icon(Icons.payments_outlined), label: const Text('Payments & disputes')),
          ],
        ]),
      ),
    );
  }

  Widget _empty() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48),
    child: Column(children: [Icon(Icons.search_off, size: 42, color: Colors.white38), SizedBox(height: 10), Text('No services yet', style: TextStyle(fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('Be the first professional to offer a service in this category.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60))]),
  );

  Future<void> _offerService() async {
    final title = TextEditingController();
    final price = TextEditingController();
    var selected = categories.length > 1 ? categories[1] : 'Services';
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Offer a professional service'),
      content: StatefulBuilder(builder: (ctx, setLocal) => Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Service title')),
        const SizedBox(height: 10),
        TextField(controller: price, decoration: const InputDecoration(labelText: 'Starting price', prefixText: 'GHS ')),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(initialValue: selected, items: categories.where((x) => x != 'All').map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setLocal(() => selected = v ?? selected), decoration: const InputDecoration(labelText: 'Category')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), FilledButton(onPressed: () async {
        await service.publishService(title: title.text.trim(), category: selected, startingPrice: price.text.trim());
        if (ctx.mounted) Navigator.pop(ctx);
      }, child: const Text('Publish'))],
    ));
  }

  Future<void> _requestQuote(Map<String, dynamic> row) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await service.createRequest(serviceId: row['id'].toString(), kind: 'quote');
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quote request submitted.')));
  }

  Future<void> _hire(Map<String, dynamic> row) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await service.createRequest(serviceId: row['id'].toString(), kind: 'hire');
    if (mounted) await Navigator.push(context, MaterialPageRoute(builder: (_) => ProfessionalBookingPage(service: row))); 
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hire request submitted for backend confirmation.')));
  }
}
