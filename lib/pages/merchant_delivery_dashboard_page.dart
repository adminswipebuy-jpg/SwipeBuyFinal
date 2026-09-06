import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/delivery_management_service.dart';

class MerchantDeliveryDashboardPage extends StatelessWidget {
  const MerchantDeliveryDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DeliveryManagementService();
    return Scaffold(
      appBar: AppBar(title: const Text('Merchant Delivery')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.merchantOrders(),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Unable to load merchant orders.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No merchant orders yet.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data();
              final status = d['status']?.toString() ?? 'pending';
              final courier = d['courierId']?.toString();
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(service.label(status)),
                  subtitle: Text(
                    'Order ${docs[i].id.substring(0, 8)} • ${d['currency'] ?? ''} ${d['subtotal'] ?? 0}'
                    '${courier == null || courier.isEmpty ? ' • Courier not assigned' : ' • Courier assigned'}',
                  ),
                  trailing: status == 'ready'
                      ? IconButton(
                          tooltip: 'Request courier',
                          icon: const Icon(Icons.local_shipping_outlined),
                          onPressed: () => service.requestCourierAssignment(docs[i].id),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
