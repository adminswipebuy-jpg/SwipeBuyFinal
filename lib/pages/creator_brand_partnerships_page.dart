import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/creator_brand_partnership_service.dart';

class CreatorBrandPartnershipsPage extends StatefulWidget {
  const CreatorBrandPartnershipsPage({super.key});
  @override
  State<CreatorBrandPartnershipsPage> createState() => _CreatorBrandPartnershipsPageState();
}

class _CreatorBrandPartnershipsPageState extends State<CreatorBrandPartnershipsPage> {
  final service = CreatorBrandPartnershipService();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Creator Brand Partnerships 2.0'),
          actions: [
            IconButton(
              tooltip: 'Safety guidance',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Brand partnership safety'),
                  content: Text('Only trusted backend systems should verify brands, enforce eligibility, manage contracts, process payments and apply sponsored-content disclosure rules.'),
                ),
              ),
              icon: const Icon(Icons.verified_user_outlined),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Turn creator reach into real partnerships', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('Prepare brand proposals, sponsored-content deliverables and partnership reviews in one place.', style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _metric('Creator-led', 'Sponsored • Affiliate • UGC', Icons.movie_filter_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _metric('Controls', 'Disclosure • Review • Payment', Icons.shield_outlined)),
            ]),
            const SizedBox(height: 14),
            _feature('Brand discovery', 'Connect to eligible brand opportunities when the trusted backend supplies them.', Icons.search_outlined),
            _feature('Proposal workspace', 'Define campaign goals, deliverables and your proposed fee before sending.', Icons.description_outlined),
            _feature('Sponsored content disclosure', 'Keep a disclosure preference attached to every partnership request.', Icons.campaign_outlined),
            _feature('Performance handoff', 'Share verified reach, engagement and conversion metrics when backend attribution is available.', Icons.insights_outlined),
            _feature('Creator protection', 'Flag suspicious requests and require backend verification before contracts or payouts.', Icons.lock_outline),
            const SizedBox(height: 16),
            const Text('My partnerships', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: service.myPartnerships(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                final docs = snap.data?.docs ?? const [];
                if (docs.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No partnership proposals yet.')));
                return Column(children: docs.map((d) {
                  final x = d.data();
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.handshake_outlined),
                      title: Text(x['brandName']?.toString() ?? 'Brand'),
                      subtitle: Text('${x['campaign'] ?? 'Campaign'} • ${x['status'] ?? 'proposal'}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'review') {
                            await service.requestReview(d.id);
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partnership sent for backend review.')));
                          }
                        },
                        itemBuilder: (_) => const [PopupMenuItem(value: 'review', child: Text('Request review'))],
                      ),
                    ),
                  );
                }).toList());
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createProposal,
          icon: const Icon(Icons.add),
          label: const Text('Partnership'),
        ),
      );

  Widget _metric(String title, String value, IconData icon) => Card(
        color: const Color(0xFF12382E),
        child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: const Color(0xFF38D9A9)), const SizedBox(height: 8), Text(value, style: const TextStyle(fontWeight: FontWeight.w900)), Text(title, style: const TextStyle(color: Colors.white60))])),
      );

  Widget _feature(String title, String subtitle, IconData icon) => Card(child: ListTile(leading: Icon(icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle)));

  Future<void> _createProposal() async {
    final brand = TextEditingController();
    final campaign = TextEditingController();
    final deliverables = TextEditingController(text: '1 short video + 2 story posts');
    final fee = TextEditingController(text: 'Quote requested');
    String disclosure = 'Sponsored / Paid partnership';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
        title: const Text('Create partnership proposal'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: brand, decoration: const InputDecoration(labelText: 'Brand name')),
          const SizedBox(height: 10),
          TextField(controller: campaign, decoration: const InputDecoration(labelText: 'Campaign')),
          const SizedBox(height: 10),
          TextField(controller: deliverables, maxLines: 2, decoration: const InputDecoration(labelText: 'Deliverables')),
          const SizedBox(height: 10),
          TextField(controller: fee, decoration: const InputDecoration(labelText: 'Proposed fee / rate')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: disclosure,
            items: const ['Sponsored / Paid partnership', 'Affiliate / commission', 'UGC / content only'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (v) => setLocal(() => disclosure = v ?? disclosure),
            decoration: const InputDecoration(labelText: 'Disclosure'),
          ),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))],
      )),
    );
    if (ok != true) return;
    try {
      final id = await service.createProposal(brandName: brand.text, campaign: campaign.text, deliverables: deliverables.text, proposedFee: fee.text, disclosure: disclosure);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Partnership proposal created: $id')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
