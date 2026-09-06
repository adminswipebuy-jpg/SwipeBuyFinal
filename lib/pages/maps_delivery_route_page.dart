import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/maps_route_service.dart';

class MapsDeliveryRoutePage extends StatefulWidget {
  final RoutePoint origin;
  final RoutePoint destination;

  const MapsDeliveryRoutePage({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  State<MapsDeliveryRoutePage> createState() => _MapsDeliveryRoutePageState();
}

class _MapsDeliveryRoutePageState extends State<MapsDeliveryRoutePage> {
  GoogleMapController? controller;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    markers.addAll({
      Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(widget.origin.latitude, widget.origin.longitude),
        infoWindow: const InfoWindow(title: 'Courier'),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.destination.latitude, widget.destination.longitude),
        infoWindow: const InfoWindow(title: 'Delivery'),
      ),
    });
  }

  void drawRoute(RouteResult route) {
    final points = route.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();
    setState(() {
      polylines
        ..clear()
        ..add(Polyline(
          polylineId: const PolylineId('delivery_route'),
          points: points,
          width: 6,
        ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(widget.destination.latitude, widget.destination.longitude);
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Route')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: center, zoom: 14),
            markers: markers,
            polylines: polylines,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (c) => controller = c,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(Icons.navigation_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Route navigation foundation. Connect the secure routing backend to draw the live road route and refresh ETA.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
