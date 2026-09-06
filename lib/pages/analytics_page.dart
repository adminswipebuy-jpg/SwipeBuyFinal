import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AnalyticsService();
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.w900))),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.contentEvents(),
        builder: (context, eventSnap) {
          final summary = service.summarizeEvents(eventSnap.data?.docs ?? const []);
          final views = (summary['views'] ?? 0).toDouble();
          final likes = (summary['likes'] ?? 0).toDouble();
          final comments = (summary['comments'] ?? 0).toDouble();
          final shares = (summary['shares'] ?? 0).toDouble();
          final saves = (summary['saves'] ?? 0).toDouble();
          final engagement = views <= 0 ? 0.0 : (likes + comments + shares + saves) / views * 100;
          final watch = (summary['watchSeconds'] ?? 0).toDouble();
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
            children: [
              const Text('Your performance', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('Track reach, engagement, audience attention and commercial performance across SwipeBuy.', style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 18),
              _MetricGrid(metrics: [
                ('Views', _fmt(views), Icons.visibility_outlined),
                ('Watch time', _duration(watch), Icons.play_circle_outline),
                ('Engagement', '${engagement.toStringAsFixed(1)}%', Icons.favorite_border),
                ('Shares', _fmt(shares), Icons.ios_share_outlined),
              ]),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Audience engagement',
                child: SizedBox(height: 180, child: _MiniBarChart(values: [likes, comments, shares, saves], labels: const ['Likes', 'Comments', 'Shares', 'Saves'])),
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: service.orders(),
                builder: (context, orderSnap) {
                  final orders = orderSnap.data?.docs ?? const [];
                  double sales = 0;
                  for (final doc in orders) {
                    final amount = doc.data()['amount'] ?? doc.data()['total'];
                    sales += amount is num ? amount.toDouble() : double.tryParse(amount?.toString() ?? '') ?? 0;
                  }
                  return _SectionCard(
                    title: 'Commerce',
                    child: Wrap(spacing: 10, runSpacing: 10, children: [
                      _ChipStat('Orders', '${orders.length}'),
                      _ChipStat('Sales', 'GHS ${sales.toStringAsFixed(2)}'),
                      _ChipStat('Conversion', views == 0 ? '0.0%' : '${(orders.length / views * 100).toStringAsFixed(2)}%'),
                    ]),
                  );
                },
              ),
              const SizedBox(height: 12),
              const _SectionCard(
                title: 'What to improve next',
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _Advice(icon: Icons.movie_filter_outlined, text: 'Double down on formats that keep people watching longer.'),
                  _Advice(icon: Icons.share_outlined, text: 'Create posts with a clear reason to share.'),
                  _Advice(icon: Icons.shopping_bag_outlined, text: 'Connect high-engagement content to products or services.'),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _fmt(double value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return value.toStringAsFixed(0);
}

String _duration(double seconds) {
  final d = Duration(seconds: seconds.round());
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) return '${h}h ${m}m';
  if (m > 0) return '${m}m ${s}s';
  return '${s}s';
}

class _MetricGrid extends StatelessWidget {
  final List<(String, String, IconData)> metrics;
  const _MetricGrid({required this.metrics});
  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
        children: metrics.map((m) => Card(
          color: const Color(0xFF111720),
          child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(m.$3, color: const Color(0xFF38D9A9)),
            const Spacer(),
            Text(m.$1, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            Text(m.$2, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          ])),
        )).toList(),
      );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Card(color: const Color(0xFF111720), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), const SizedBox(height: 12), child]));
}

class _ChipStat extends StatelessWidget {
  final String label, value;
  const _ChipStat(this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)), Text(value, style: const TextStyle(fontWeight: FontWeight.w900))]));
}

class _Advice extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Advice({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 20, color: const Color(0xFF38D9A9)), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(color: Colors.white70)))]));
}

class _MiniBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  const _MiniBarChart({required this.values, required this.labels});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _BarPainter(values, labels), child: const SizedBox.expand());
}

class _BarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  _BarPainter(this.values, this.labels);
  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = values.fold<double>(1, (a, b) => b > a ? b : a);
    final barWidth = size.width / (values.length * 2.0);
    for (var i = 0; i < values.length; i++) {
      final x = (i * 2 + 0.75) * barWidth;
      final h = values[i] / maxValue * (size.height - 34);
      final paint = Paint()..color = const Color(0xFF38D9A9);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height - 34 - h, barWidth, h), const Radius.circular(8)), paint);
      final tp = TextPainter(text: TextSpan(text: labels[i], style: const TextStyle(color: Colors.white54, fontSize: 11)), textDirection: TextDirection.ltr)..layout(maxWidth: barWidth * 1.8);
      tp.paint(canvas, Offset(x - barWidth * .25, size.height - 28));
    }
  }
  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) => oldDelegate.values != values;
}
