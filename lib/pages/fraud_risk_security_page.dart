import 'package:flutter/material.dart';
import '../services/fraud_risk_service.dart';

class FraudRiskSecurityPage extends StatefulWidget {
  const FraudRiskSecurityPage({super.key});
  @override
  State<FraudRiskSecurityPage> createState() => _FraudRiskSecurityPageState();
}

class _FraudRiskSecurityPageState extends State<FraudRiskSecurityPage> {
  final service = FraudRiskService();
  final transactionId = TextEditingController();
  String reportReason = 'Suspicious transaction';
  bool busy = false;

  @override
  void dispose() {
    transactionId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fraud Prevention & Security 2.0')),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: service.watchMine(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final band = (data?['riskBand'] ?? 'Not scored').toString();
          final status = (data?['status'] ?? 'Backend monitoring').toString();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _hero(band, status),
              const SizedBox(height: 16),
              _protectionCard(),
              const SizedBox(height: 14),
              _accountReviewCard(),
              const SizedBox(height: 14),
              _reportCard(),
              const SizedBox(height: 14),
              _principlesCard(),
              const SizedBox(height: 90),
            ],
          );
        },
      ),
    );
  }

  Widget _hero(String band, String status) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF241B10), Color(0xFF111827)],
          ),
          border: Border.all(color: const Color(0xFFF59E0B).withOpacity(.22)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.gpp_good_outlined, color: Color(0xFFF59E0B), size: 28),
            SizedBox(width: 10),
            Text('Safer transactions. Safer marketplace.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 9),
          const Text('SwipeBuy uses backend risk systems to protect buyers, sellers, professionals, creators and accounts.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            Chip(label: Text('Risk: $band')),
            Chip(label: Text(status)),
          ]),
        ]),
      );

  Widget _protectionCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Protection layers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            _line(Icons.lock_outline, 'Payment and payout anomaly detection'),
            _line(Icons.person_search_outlined, 'Identity + verification signals'),
            _line(Icons.storefront_outlined, 'Seller and professional risk checks'),
            _line(Icons.local_shipping_outlined, 'Order and delivery risk monitoring'),
            _line(Icons.report_gmailerrorred_outlined, 'Dispute and abuse signals'),
          ]),
        ),
      );

  Widget _line(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [Icon(icon, size: 20), const SizedBox(width: 10), Expanded(child: Text(text))]),
      );

  Widget _accountReviewCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Request a security review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            const Text('Ask the protected backend risk team to review unusual activity on your account.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: busy ? null : _requestReview,
              icon: const Icon(Icons.shield_outlined),
              label: Text(busy ? 'Submitting…' : 'Request review'),
            ),
          ]),
        ),
      );

  Widget _reportCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Report a transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            TextField(controller: transactionId, decoration: const InputDecoration(labelText: 'Transaction / order ID')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: reportReason,
              items: const [
                DropdownMenuItem(value: 'Suspicious transaction', child: Text('Suspicious transaction')),
                DropdownMenuItem(value: 'Unauthorized activity', child: Text('Unauthorized activity')),
                DropdownMenuItem(value: 'Possible scam', child: Text('Possible scam')),
                DropdownMenuItem(value: 'Payment issue', child: Text('Payment issue')),
              ],
              onChanged: (v) => setState(() => reportReason = v ?? reportReason),
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: _report, icon: const Icon(Icons.flag_outlined), label: const Text('Send report')),
          ]),
        ),
      );

  Widget _principlesCard() => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Security principles', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            SizedBox(height: 8),
            Text('Risk scores, holds, transaction approvals, account restrictions and fraud decisions must be calculated and enforced by trusted backend services—not by client-side code.', style: TextStyle(color: Colors.white70)),
          ]),
        ),
      );

  Future<void> _requestReview() async {
    setState(() => busy = true);
    try {
      await service.requestAccountReview();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Security review request submitted.')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _report() async {
    try {
      await service.reportTransaction(transactionId: transactionId.text, reason: reportReason);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction report submitted for backend review.')));
      transactionId.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
