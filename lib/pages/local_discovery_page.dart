import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/local_discovery_service.dart';
import '../services/maps_route_service.dart';
import 'maps_delivery_route_page.dart';

class LocalDiscoveryPage extends StatefulWidget {
  const LocalDiscoveryPage({super.key});

  @override
  State<LocalDiscoveryPage> createState() => _LocalDiscoveryPageState();
}

class _LocalDiscoveryPageState extends State<LocalDiscoveryPage> {
  final service = LocalDiscoveryService();
  Position? position;
  List<NearbyItem> items = const [];
  String category = '';
  double radius = 10;
  bool busy = true;
  String? error;

  final categories = const ['All', 'Food', 'Hotels', 'Jobs', 'Property', 'Services', 'Beauty', 'Entertainment'];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final p = await service.currentPosition();
      final list = await service.nearby(
        latitude: p.latitude,
        longitude: p.longitude,
        category: category.isEmpty ? null : category,
        radiusKm: radius,
      );
      if (!mounted) return;
      setState(() {
        position = p;
        items = list;
      });
    } on LocationServiceDisabledException {
      if (mounted) setState(() => error = 'Turn on location services to discover what is near you.');
    } on PermissionDeniedException {
      if (mounted) setState(() => error = 'Location permission is needed for Nearby. You can enable it in Android settings.');
    } catch (_) {
      if (mounted) setState(() => error = 'Could not load nearby places right now.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Nearby'),
          actions: [
            IconButton(onPressed: busy ? null : refresh, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 6),
            _filters(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      position == null
                          ? 'Finding your location…'
                          : 'Using your current location • ${radius.toStringAsFixed(0)} km radius',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton(onPressed: busy ? null : refresh, child: const Text('Update')),
                ],
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: Card(
                  color: const Color(0xFF2A1C12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orangeAccent),
                        const SizedBox(width: 10),
                        Expanded(child: Text(error!)),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: busy
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? _empty()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _itemCard(items[i]),
                        ),
            ),
          ],
        ),
      );

  Widget _filters() => SizedBox(
        height: 46,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 7),
          itemBuilder: (_, i) {
            final name = categories[i];
            final selected = (name == 'All' && category.isEmpty) || category == name;
            return ChoiceChip(
              label: Text(name),
              selected: selected,
              onSelected: (_) {
                setState(() => category = name == 'All' ? '' : name);
                refresh();
              },
            );
          },
        ),
      );

  Widget _itemCard(NearbyItem item) => Card(
        color: const Color(0xFF111720),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                        Row(
                          children: [
                            Flexible(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))),
                            if (item.verified) ...[
                              const SizedBox(width: 5),
                              const Icon(Icons.verified, size: 18, color: Color(0xFF38D9A9)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text('${item.category} • ${item.location}', style: const TextStyle(color: Colors.white60)),
                      ],
                    ),
                  ),
                  Text('${item.distanceKm.toStringAsFixed(1)} km', style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 12),
              Text(item.subtitle, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: position == null
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MapsDeliveryRoutePage(
                                  origin: RoutePoint(position!.latitude, position!.longitude),
                                  destination: RoutePoint(item.latitude, item.longitude),
                                ),
                              ),
                            ),
                    icon: const Icon(Icons.directions_outlined),
                    label: const Text('Directions'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_actionFor(item.category)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _empty() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 44),
          const Icon(Icons.explore_off_outlined, size: 68, color: Colors.white38),
          const SizedBox(height: 14),
          const Center(child: Text('Nothing nearby yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
          const SizedBox(height: 8),
          const Center(child: Text('Businesses and listings with verified coordinates will appear here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60))),
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: refresh, icon: const Icon(Icons.my_location), label: const Text('Try again')),
        ],
      );

  IconData _iconFor(String c) {
    switch (c) {
      case 'Food': return Icons.restaurant;
      case 'Hotels': return Icons.hotel;
      case 'Jobs': return Icons.work;
      case 'Property': return Icons.home_work;
      case 'Services': return Icons.build;
      case 'Beauty': return Icons.spa;
      case 'Entertainment': return Icons.music_note;
      default: return Icons.place;
    }
  }

  String _actionFor(String c) {
    switch (c) {
      case 'Food': return 'Order';
      case 'Hotels': return 'Book';
      case 'Jobs': return 'Apply';
      case 'Property': return 'View';
      case 'Services': return 'Hire';
      case 'Beauty': return 'Book';
      case 'Entertainment': return 'Get Ticket';
      default: return 'Open';
    }
  }
}
