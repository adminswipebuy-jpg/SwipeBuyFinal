import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/digital_product_service.dart';

class DigitalProductsPage extends StatefulWidget {
  const DigitalProductsPage({super.key});
  @override State<DigitalProductsPage> createState() => _DigitalProductsPageState();
}

class _DigitalProductsPageState extends State<DigitalProductsPage> with SingleTickerProviderStateMixin {
  late final TabController tabs = TabController(length: 3, vsync: this);
  final service = DigitalProductService();

  @override
  void dispose() { tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Digital Products & Downloads 2.0', style: TextStyle(fontWeight: FontWeight.w900)),
      bottom: TabBar(controller: tabs, tabs: const [Tab(text: 'Marketplace'), Tab(text: 'My Library'), Tab(text: 'Sell')]),
    ),
    body: TabBarView(controller: tabs, children: [_marketplace(), _library(), _sell()]),
  );

  Widget _marketplace() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: service.publishedProducts(),
    builder: (_, snap) {
      if (snap.hasError) return const Center(child: Text('Unable to load digital products right now.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return const _Empty(icon: Icons.file_download_outlined, title: 'No digital products yet', subtitle: 'Creators can publish courses, templates, guides, presets and downloadable resources.');
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: docs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final d = docs[i].data();
          final id = docs[i].id;
          return Card(color: const Color(0xFF111720), child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              const CircleAvatar(child: Icon(Icons.auto_awesome_outlined)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d['title']?.toString() ?? 'Digital product', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                const SizedBox(height: 4),
                Text('${d['category'] ?? 'Digital'} • ${d['fileType'] ?? 'Download'}', style: const TextStyle(color: Colors.white60)),
                const SizedBox(height: 5),
                Text(d['description']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54)),
              ])),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(d['priceLabel']?.toString() ?? 'Checkout', style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                FilledButton(onPressed: () => _buy(id), child: const Text('Buy')),
              ]),
            ]),
          ));
        },
      );
    },
  );

  Widget _library() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: service.myLibrary(),
    builder: (_, snap) {
      if (snap.hasError) return const Center(child: Text('Unable to load your digital library.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return const _Empty(icon: Icons.library_books_outlined, title: 'Your library is empty', subtitle: 'Purchased and verified digital products will appear here.');
      return ListView.separated(
        padding: const EdgeInsets.all(16), itemCount: docs.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final d = docs[i].data();
          final id = docs[i].id;
          return Card(color: const Color(0xFF111720), child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.download_outlined)),
            title: Text(d['productTitle']?.toString() ?? 'Digital product', style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text('${d['status'] ?? 'verified'} • ${d['license'] ?? 'Standard license'}'),
            trailing: FilledButton.icon(onPressed: () => service.requestDownload(entitlementId: id), icon: const Icon(Icons.download), label: const Text('Download')),
          ));
        },
      );
    },
  );

  Widget _sell() => ListView(padding: const EdgeInsets.all(18), children: [
    const Text('Sell digital products', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
    const SizedBox(height: 8),
    const Text('Sell courses, templates, ebooks, presets, guides and other creator resources. Payment, licensing, file delivery, entitlement checks and refunds are handled by trusted backend services.', style: TextStyle(color: Colors.white54)),
    const SizedBox(height: 16),
    FilledButton.icon(onPressed: _publish, icon: const Icon(Icons.add), label: const Text('Publish a digital product')),
    const SizedBox(height: 14),
    const _Info(icon: Icons.school_outlined, title: 'Courses & guides', subtitle: 'Educational resources and learning materials.'),
    const _Info(icon: Icons.design_services_outlined, title: 'Templates & presets', subtitle: 'Design, business, creator and productivity assets.'),
    const _Info(icon: Icons.menu_book_outlined, title: 'Ebooks & downloads', subtitle: 'Files delivered only after verified entitlement.'),
  ]);

  Future<void> _buy(String id) async {
    await service.requestPurchase(productId: id);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase request saved for secure checkout.')));
  }

  Future<void> _publish() async {
    final title = TextEditingController();
    final desc = TextEditingController();
    final price = TextEditingController();
    String category = 'Templates';
    String type = 'PDF';
    await showDialog(context: context, builder: (context) => StatefulBuilder(builder: (_, setModal) => AlertDialog(
      title: const Text('Publish digital product'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
        TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
        TextField(controller: price, decoration: const InputDecoration(labelText: 'Price label e.g. GHS 80')),
        DropdownButtonFormField<String>(value: category, items: const ['Templates','Courses','Ebooks','Presets','Guides','Other'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setModal(() => category = v ?? category)),
        DropdownButtonFormField<String>(value: type, items: const ['PDF','ZIP','Video course','Audio','Design preset','Other'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setModal(() => type = v ?? type)),
        const SizedBox(height: 8),
        const Text('File upload, licensing, malware scanning, payment and entitlement verification must be completed by trusted backend services.', style: TextStyle(color: Colors.white54)),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async { await service.publishProduct(title: title.text, description: desc.text, category: category, priceLabel: price.text, fileType: type); if (context.mounted) Navigator.pop(context); }, child: const Text('Submit'))],
    )));
    title.dispose(); desc.dispose(); price.dispose();
  }
}

class _Info extends StatelessWidget { final IconData icon; final String title, subtitle; const _Info({required this.icon, required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Card(color: const Color(0xFF111720), child: ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle))); }
class _Empty extends StatelessWidget { final IconData icon; final String title, subtitle; const _Empty({required this.icon, required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 58, color: Colors.white30), const SizedBox(height: 14), Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54))]))); }
