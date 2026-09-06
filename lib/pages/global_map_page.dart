import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../services/local_discovery_service.dart';

class GlobalMapPage extends StatefulWidget {
  const GlobalMapPage({super.key});

  @override
  State<GlobalMapPage> createState() => _GlobalMapPageState();
}

class _GlobalMapPageState extends State<GlobalMapPage> {
  final LocalDiscoveryService service = LocalDiscoveryService();
  GoogleMapController? mapController;
  final Set<Marker> markers = <Marker>{};
  Position? position;
  List<NearbyItem> nearbyItems = const [];
  String selectedCategory = 'All';
  double radiusKm = 10;
  bool loading = true;
  String? error;

  final categories = const [
    'All', 'Food', 'Hotels', 'Jobs', 'Property', 'Services',
    'Beauty', 'Entertainment', 'Shopping', 'Events',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final p = await service.currentPosition();
      final items = await service.nearby(
        latitude: p.latitude,
        longitude: p.longitude,
        category: selectedCategory == 'All' ? null : selectedCategory,
        radiusKm: radiusKm,
      );
      final nextMarkers = <Marker>{
        Marker(
          markerId: const MarkerId('me'),
          position: LatLng(p.latitude, p.longitude),
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      };
      for (final item in items) {
        nextMarkers.add(
          Marker(
            markerId: MarkerId(item.id),
            position: LatLng(item.latitude, item.longitude),
            infoWindow: InfoWindow(title: item.title, snippet: item.category),
            onTap: () => _showItem(item),
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        position = p;
        nearbyItems = items;
        markers
          ..clear()
          ..addAll(nextMarkers);
      });
      await mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(p.latitude, p.longitude), 13),
      );
    } on LocationServiceDisabledException {
      if (mounted) setState(() => error = 'Turn on location services to use the SwipeBuy map.');
    } on PermissionDeniedException {
      if (mounted) setState(() => error = 'Location permission is required for Nearby Map.');
    } catch (_) {
      if (mounted) setState(() => error = 'Could not load map data right now.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showItem(NearbyItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111720),
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF173A31),
                    child: Icon(_iconFor(item.category), color: const Color(0xFF38D9A9)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        Text('${item.category} • ${item.distanceKm.toStringAsFixed(1)} km away', style: const TextStyle(color: Colors.white60)),
                      ],
                    ),
                  ),
                  if (item.verified) const Icon(Icons.verified, color: Color(0xFF38D9A9)),
                ],
              ),
              const SizedBox(height: 12),
              Text(item.subtitle, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.visibility_outlined), label: const Text('View'))),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.near_me_outlined), label: const Text('Navigate'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fallback = const LatLng(6.6885, -1.6244); // Ghana fallback center.
    final center = position == null ? fallback : LatLng(position!.latitude, position!.longitude);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwipeBuy Map'),
        actions: [
          IconButton(onPressed: loading ? null : _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: center, zoom: 6.5),
            myLocationEnabled: position != null,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: markers,
            onMapCreated: (controller) {
              mapController = controller;
              if (position != null) {
                controller.moveCamera(CameraUpdate.newLatLngZoom(center, 13));
              }
            },
            onTap: (_) {},
          ),
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Column(
              children: [
                _searchBar(),
                const SizedBox(height: 8),
                _categoryChips(),
              ],
            ),
          ),
          if (error != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 124,
              child: Card(
                color: const Color(0xFF2A1C12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orangeAccent),
                      const SizedBox(width: 8),
                      Expanded(child: Text(error!)),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            right: 14,
            bottom: 118,
            child: FloatingActionButton.small(
              heroTag: 'locate',
              onPressed: position == null ? _load : () => mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(position!.latitude, position!.longitude), 14)),
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: _nearbySummary(),
          ),
          if (loading)
            const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 3)),
        ],
      ),
    );
  }

  Widget _searchBar() => Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF111720),
        child: TextField(
          readOnly: true,
          onTap: () {},
          decoration: const InputDecoration(
            hintText: 'Ask SwipeBuy: restaurants, jobs, houses…',
            prefixIcon: Icon(Icons.search),
            suffixIcon: Icon(Icons.auto_awesome),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );

  Widget _categoryChips() => SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            final category = categories[i];
            return ChoiceChip(
              label: Text(category),
              selected: selectedCategory == category,
              onSelected: (_) {
                setState(() => selectedCategory = category);
                _load();
              },
            );
          },
        ),
      );

  Widget _nearbySummary() => Card(
        color: const Color(0xE80B1017),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              const Icon(Icons.explore_outlined, color: Color(0xFF38D9A9)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${nearbyItems.length} things nearby', style: const TextStyle(fontWeight: FontWeight.w900)),
                    Text('${selectedCategory == 'All' ? 'Everything' : selectedCategory} • ${radiusKm.toStringAsFixed(0)} km radius', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuButton<double>(
                tooltip: 'Radius',
                icon: const Icon(Icons.tune),
                onSelected: (value) {
                  setState(() => radiusKm = value);
                  _load();
                },
                itemBuilder: (_) => [5.0, 10.0, 25.0, 50.0].map((v) => PopupMenuItem<double>(value: v, child: Text('${v.toStringAsFixed(0)} km'))).toList(),
              ),
            ],
          ),
        ),
      );

  IconData _iconFor(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant;
      case 'Hotels': return Icons.hotel;
      case 'Jobs': return Icons.work;
      case 'Property': return Icons.home_work;
      case 'Services': return Icons.build;
      case 'Beauty': return Icons.spa;
      case 'Entertainment': return Icons.music_note;
      case 'Shopping': return Icons.shopping_bag;
      case 'Events': return Icons.event;
      default: return Icons.place;
    }
  }
}
