import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/live_delivery_tracking_service.dart';

class LiveDeliveryTrackingPage extends StatelessWidget {
  final String orderId;
  const LiveDeliveryTrackingPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final service = LiveDeliveryTrackingService();
    return Scaffold(
      appBar: AppBar(title: const Text('Live Delivery')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: service.order(orderId),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Unable to track delivery.'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!.data();
          if (data == null) return const Center(child: Text('Order not found.'));

          final point = data['courierLocation'] as GeoPoint?;
          final eta = data['estimatedDeliveryAt'];
          final status = data['status']?.toString() ?? 'pending';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(Icons.location_on_outlined, size: 64),
              const SizedBox(height: 12),
              Text(status.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                height: 260,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(),
                ),
                child: const Text(
                  'Map view foundation\nConnect Google Maps here with a server-validated route.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Estimated arrival'),
                subtitle: Text(eta?.toString() ?? 'Calculating...'),
              ),
              if (point != null)
                ListTile(
                  leading: const Icon(Icons.my_location),
                  title: const Text('Courier location'),
                  subtitle: Text('${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}'),
                ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Destination'),
                subtitle: Text((data['deliveryAddress'] ?? 'Not provided').toString()),
              ),
            ],
          );
        },
      ),
    );
  }
}
