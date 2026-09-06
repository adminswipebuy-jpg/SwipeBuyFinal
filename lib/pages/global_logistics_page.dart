import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/global_logistics_service.dart';
import 'live_delivery_tracking_page.dart';

class GlobalLogisticsPage extends StatelessWidget {
  const GlobalLogisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = GlobalLogisticsService();
    return Scaffold(
      appBar: AppBar(title: const Text('Global Logistics 2.0')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.myShipments(),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Unable to load shipments.'));
          final docs = snap.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text('Ship anywhere', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('Cross-border delivery, courier assignment and shipment tracking in one place.', style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: _card(Icons.public, 'International', 'Country-aware shipping')),
                const SizedBox(width: 10),
                Expanded(child: _card(Icons.local_shipping_outlined, 'Delivery', 'Pickup to doorstep')),
                const SizedBox(width: 10),
                Expanded(child: _card(Icons.track_changes, 'Tracking', 'Live status foundation')),
              ]),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Cross-border quote', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    const Text('Request a trusted backend/provider quote with delivery time, duties and fees before you pay.'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () async {
                        await service.requestCrossBorderQuote(
                          orderId: 'order_demo',
                          destinationCountry: 'Ghana',
                          serviceLevel: 'Express',
                        );
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quote request submitted.')));
                      },
                      icon: const Icon(Icons.request_quote_outlined),
                      label: const Text('Request shipping quote'),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 18),
              const Text('My shipments', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              if (snap.connectionState == ConnectionState.waiting)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else if (docs.isEmpty)
                const Card(child: ListTile(leading: Icon(Icons.inventory_2_outlined), title: Text('No shipments yet'), subtitle: Text('Orders with delivery will appear here.')))
              else
                ...docs.map((doc) {
                  final d = doc.data();
                  final status = (d['status'] ?? 'label_created').toString();
                  final carrier = (d['carrierName'] ?? 'Carrier pending').toString();
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_shipping_outlined),
                      title: Text(status.replaceAll('_', ' ').toUpperCase()),
                      subtitle: Text('$carrier • ${d['destinationCountry'] ?? 'Destination pending'}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LiveDeliveryTrackingPage(orderId: doc.id))),
                    ),
                  );
                }),
              const SizedBox(height: 12),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.policy_outlined),
                  title: Text('Customs & buyer protection'),
                  subtitle: Text('Final duties, restricted-item checks and protection decisions must be confirmed by trusted backend services.'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _card(IconData icon, String title, String subtitle) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFF111720), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon), const SizedBox(height: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54)),
    ]),
  );
}
