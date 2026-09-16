import 'package:flutter/material.dart';
import '../services/global_payment_service.dart';
import 'wallet_page.dart';

class GlobalPaymentsPage extends StatefulWidget {
  const GlobalPaymentsPage({super.key});

  @override
  State<GlobalPaymentsPage> createState() => _GlobalPaymentsPageState();
}

class _GlobalPaymentsPageState extends State<GlobalPaymentsPage> {
  final service = GlobalPaymentService();
  String country = 'Ghana';
  String currency = 'GHS';
  String provider = 'Mobile Money';
  bool saving = false;

  static const countries = <String, String>{
    'Ghana': 'GHS',
    'Nigeria': 'NGN',
    'Kenya': 'KES',
    'South Africa': 'ZAR',
    'United States': 'USD',
    'United Kingdom': 'GBP',
    'Eurozone': 'EUR',
  };

  static const providers = ['Mobile Money', 'Card', 'Bank transfer', 'SwipeBuy Wallet'];

  Future<void> _save() async {
    setState(() => saving = true);
    try {
      await service.savePreferences(country: country, currency: currency, provider: provider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment preferences saved.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Global Payments', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFF182A24), Color(0xFF111720)]),
            border: Border.all(color: Colors.white10),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.public, size: 34),
            SizedBox(height: 10),
            Text('Pay across borders', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            SizedBox(height: 6),
            Text('Choose your default country, currency and payment method. Payment authorization remains with trusted providers and backend services.', style: TextStyle(color: Colors.white70, height: 1.4)),
          ]),
        ),
        const SizedBox(height: 18),
        _label('Country'),
        DropdownButtonFormField<String>(
          initialValue: country,
          decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.flag_outlined)),
          items: countries.keys.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() { country = value; currency = countries[value]!; });
          },
        ),
        const SizedBox(height: 14),
        _label('Currency'),
        DropdownButtonFormField<String>(
          initialValue: currency,
          decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.currency_exchange)),
          items: countries.values.toSet().map((code) => DropdownMenuItem(value: code, child: Text(code))).toList(),
          onChanged: (value) => setState(() => currency = value ?? currency),
        ),
        const SizedBox(height: 14),
        _label('Default payment method'),
        DropdownButtonFormField<String>(
          initialValue: provider,
          decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.payments_outlined)),
          items: providers.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
          onChanged: (value) => setState(() => provider = value ?? provider),
        ),
        const SizedBox(height: 20),
        SizedBox(height: 54, child: FilledButton.icon(
          onPressed: saving ? null : _save,
          icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
          label: Text(saving ? 'Saving…' : 'Save payment preferences'),
        )),
        const SizedBox(height: 14),
        Card(child: Column(children: [
          const ListTile(leading: Icon(Icons.account_balance_wallet_outlined), title: Text('SwipeBuy Wallet', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('Manage deposits, withdrawals and wallet transactions')), 
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletPage())), child: const Text('Open Wallet')),
        ])),
        const SizedBox(height: 8),
        const Card(child: Padding(padding: EdgeInsets.all(14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.verified_user_outlined), SizedBox(width: 10), Expanded(child: Text('Safety note: saved preferences do not store card numbers, PINs or mobile-money authorization secrets. Final payment confirmation must come from the payment provider/backend.', style: TextStyle(color: Colors.white70, height: 1.4))),
        ]))),
      ]),
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)));
}
