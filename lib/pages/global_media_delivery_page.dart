import 'package:flutter/material.dart';
import '../services/global_media_delivery_service.dart';

class GlobalMediaDeliveryPage extends StatefulWidget {
  const GlobalMediaDeliveryPage({super.key});
  @override State<GlobalMediaDeliveryPage> createState() => _GlobalMediaDeliveryPageState();
}

class _GlobalMediaDeliveryPageState extends State<GlobalMediaDeliveryPage> {
  final service = GlobalMediaDeliveryService();
  bool saving = false;
  String mode = 'Adaptive';
  String region = 'Auto';
  bool wifiOnly = false;
  bool preload = true;

  Future<void> save() async {
    setState(() => saving = true);
    await service.savePreferences(mode: mode, region: region, wifiOnly: wifiOnly, preload: preload);
    if (mounted) setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Delivery & Video Performance')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Global CDN & Media Delivery 2.0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Optimize video, images and downloads for faster playback across regions.'),
          const SizedBox(height: 18),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.speed), title: const Text('Adaptive delivery'), subtitle: const Text('Choose the best media quality for the network.'), trailing: DropdownButton<String>(value: mode, items: const ['Adaptive','Data Saver','Maximum Quality'].map((e) => DropdownMenuItem(value:e, child:Text(e))).toList(), onChanged: (v)=>setState(()=>mode=v!))),
            ListTile(leading: const Icon(Icons.public), title: const Text('Preferred edge region'), subtitle: const Text('Route media toward the nearest available edge.'), trailing: DropdownButton<String>(value: region, items: const ['Auto','West Africa','Europe','North America','Asia-Pacific'].map((e)=>DropdownMenuItem(value:e, child:Text(e))).toList(), onChanged:(v)=>setState(()=>region=v!))),
            SwitchListTile(value: wifiOnly, onChanged:(v)=>setState(()=>wifiOnly=v), title: const Text('Wi-Fi-only prefetch'), subtitle: const Text('Avoid background media prefetch on mobile data.')),
            SwitchListTile(value: preload, onChanged:(v)=>setState(()=>preload=v), title: const Text('Predictive preloading'), subtitle: const Text('Preload likely next content when conditions allow.')),
          ])),
          const SizedBox(height: 12),
          Card(child: Column(children: [
            const ListTile(leading: Icon(Icons.movie_filter_outlined), title: Text('Media health'), subtitle: Text('Operational signals are collected server-side.')),
            _metric('Video start time', 'Target < 2.0s'),
            _metric('Playback failures', 'Target < 1%'),
            _metric('CDN cache hit rate', 'Target > 90%'),
            _metric('Image delivery', 'Optimized'),
          ])),
          const SizedBox(height: 12),
          Card(child: Column(children: [
            const ListTile(leading: Icon(Icons.admin_panel_settings_outlined), title: Text('Infrastructure controls'), subtitle: Text('Provider, CDN, transcoding and purge actions stay backend-controlled.')),
            ListTile(leading: const Icon(Icons.cleaning_services_outlined), title: const Text('Request cache purge'), onTap: ()=>service.request('cache_purge')),
            ListTile(leading: const Icon(Icons.video_settings_outlined), title: const Text('Request media optimization'), onTap: ()=>service.request('media_optimization')),
            ListTile(leading: const Icon(Icons.public_off_outlined), title: const Text('Request regional failover review'), onTap: ()=>service.request('regional_failover_review')),
          ])),
          const SizedBox(height: 16),
          SizedBox(height: 52, child: FilledButton(onPressed: saving ? null : save, child: Text(saving ? 'Saving…' : 'Save Delivery Preferences'))),
        ],
      ),
    );
  }

  Widget _metric(String a, String b) => ListTile(dense: true, title: Text(a), trailing: Text(b, style: const TextStyle(color: Colors.white70)));
}
