import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/order_tracking_service.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = OrderTrackingService();
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.customerOrders(),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Unable to load orders.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No orders yet.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data();
              final status = d['status']?.toString() ?? 'pending';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: ListTile(
                  leading: const Icon(Icons.local_shipping_outlined),
                  title: Text(service.statusLabel(status)),
                  subtitle: Text(
                    '${d['deliveryMethod'] ?? 'fulfilment'} • ${d['currency'] ?? ''} ${d['subtotal'] ?? 0}',
                  ),
                  trailing: Text(d['paymentStatus']?.toString() ?? 'unpaid'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderTrackingDetailPage(orderId: docs[i].id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class OrderTrackingDetailPage extends StatelessWidget {
  final String orderId;
  const OrderTrackingDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final service = OrderTrackingService();
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: service.order(orderId),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Unable to load order.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!.data();
          if (d == null) return const Center(child: Text('Order not found.'));
          final status = d['status']?.toString() ?? 'pending';
          final steps = [
            'pending', 'confirmed', 'preparing', 'ready',
            'picked_up', 'out_for_delivery', 'delivered'
          ];
          final current = steps.indexOf(status);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(service.statusLabel(status),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...List.generate(steps.length, (i) {
                final active = current >= i && current >= 0;
                return ListTile(
                  leading: Icon(active ? Icons.check_circle : Icons.radio_button_unchecked),
                  title: Text(service.statusLabel(steps[i])),
                );
              }),
              const Divider(),
              Text('Payment: ${d['paymentStatus'] ?? 'unpaid'}'),
              Text('Total: ${d['currency'] ?? ''} ${d['subtotal'] ?? 0}'),
              if ((d['deliveryAddress'] ?? '').toString().isNotEmpty)
                Text('Delivery: ${d['deliveryAddress']}'),
            ],
          );
        },
      ),
    );
  }
}
