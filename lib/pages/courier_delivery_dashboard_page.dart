import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/delivery_management_service.dart';

class CourierDeliveryDashboardPage extends StatelessWidget {
  const CourierDeliveryDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DeliveryManagementService();
    return Scaffold(
      appBar: AppBar(title: const Text('Courier Jobs')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.courierJobs(),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Unable to load courier jobs.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No assigned deliveries.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data();
              final status = d['status']?.toString() ?? 'picked_up';
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.delivery_dining),
                  title: Text(service.label(status)),
                  subtitle: Text((d['deliveryAddress'] ?? 'Address unavailable').toString()),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
