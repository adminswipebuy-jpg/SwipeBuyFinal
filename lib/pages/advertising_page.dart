import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_monetization_service.dart';

class AdvertisingPage extends StatefulWidget {
  const AdvertisingPage({super.key});
  @override
  State<AdvertisingPage> createState() => _AdvertisingPageState();
}

class _AdvertisingPageState extends State<AdvertisingPage> {
  BannerAd? _banner;
  bool _bannerReady = false;

  @override
  void initState() {
    super.initState();
    AdMonetizationService.preloadInterstitial();
    _banner = AdMonetizationService.createBanner(
      size: AdSize.banner,
      onLoaded: () { if (mounted) setState(() => _bannerReady = true); },
      onFailed: (_) { if (mounted) setState(() => _bannerReady = false); },
    );
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  Widget _card(String title, String body, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(child: Icon(icon)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(color: Colors.white60, height: 1.35)),
        ])),
      ]),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SwipeBuy Ads')), 
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Monetization & advertising', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Ads should support the business without overwhelming the feed.', style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 18),
        _card('Native feed ads', 'Reserve carefully placed sponsored cards that match the SwipeBuy feed format.', Icons.view_stream),
        _card('Promoted products', 'Let businesses boost products or services with transparent sponsored labels.', Icons.campaign),
        _card('Creator monetization', 'Connect paid partnerships, subscriptions and ad revenue to creator analytics.', Icons.star_outline),
        _card('Ad controls', 'Provide frequency caps, category controls and clear sponsored labels.', Icons.tune),
        const SizedBox(height: 18),
        if (_bannerReady && _banner != null)
          Center(child: SizedBox(width: _banner!.size.width.toDouble(), height: 50, child: AdWidget(ad: _banner!)))
        else
          const Center(child: Padding(padding: EdgeInsets.all(18), child: Text('Test ad slot ready for configuration.', style: TextStyle(color: Colors.white38)))),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () async {
            await AdMonetizationService.showInterstitialIfReady();
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Interstitial slot tested.')));
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Test full-screen ad slot'),
        ),
        const SizedBox(height: 12),
        const Text('Development note: this build uses Google test ad unit IDs. Replace them with your own AdMob IDs before production.', style: TextStyle(color: Colors.amberAccent, fontSize: 12)),
      ],
    ),
  );
}
