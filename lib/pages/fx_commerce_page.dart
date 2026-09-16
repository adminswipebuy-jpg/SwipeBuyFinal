import 'package:flutter/material.dart';
import '../services/fx_commerce_service.dart';

class FxCommercePage extends StatefulWidget {
  const FxCommercePage({super.key});
  @override
  State<FxCommercePage> createState() => _FxCommercePageState();
}

class _FxCommercePageState extends State<FxCommercePage> {
  final service = FxCommerceService();
  final amountController = TextEditingController(text: '100');
  String from = 'GHS';
  String to = 'USD';
  String displayCurrency = 'GHS';
  bool showLocal = true;
  bool showEstimatedFx = true;
  bool saving = false;

  static const currencies = ['GHS','NGN','KES','ZAR','USD','GBP','EUR'];

  @override
  void dispose() { amountController.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => saving = true);
    try {
      await service.saveCommercePreferences(
        displayCurrency: displayCurrency,
        showLocalCurrency: showLocal,
        showEstimatedFx: showEstimatedFx,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('FX preferences saved.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { if (mounted) setState(() => saving = false); }
  }

  Future<void> _quote() async {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount.')));
      return;
    }
    try {
      final id = await service.requestQuote(amount: amount, fromCurrency: from, toCurrency: to);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('FX quote requested: $id')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('International Commerce & FX 2.0', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF1A2635), Color(0xFF111720)]), border: Border.all(color: Colors.white10)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.currency_exchange_rounded, size: 34),
            SizedBox(height: 10),
            Text('Shop globally with clear prices', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            SizedBox(height: 6),
            Text('Keep local prices visible while preparing multi-currency checkout. Final FX rates must be supplied by a trusted backend or payment provider.', style: TextStyle(color: Colors.white70, height: 1.4)),
          ]),
        ),
        const SizedBox(height: 18),
        const Text('Display preferences', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(initialValue: displayCurrency, decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.payments_outlined), labelText: 'Preferred display currency'), items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => displayCurrency = v ?? displayCurrency)),
        SwitchListTile(value: showLocal, onChanged: (v) => setState(() => showLocal = v), title: const Text('Show seller/local currency'), subtitle: const Text('Useful when buying across countries.')),
        SwitchListTile(value: showEstimatedFx, onChanged: (v) => setState(() => showEstimatedFx = v), title: const Text('Show estimated FX'), subtitle: const Text('Label estimates clearly until the final payment quote is confirmed.')),
        SizedBox(height: 52, child: FilledButton.icon(onPressed: saving ? null : _save, icon: const Icon(Icons.save_outlined), label: Text(saving ? 'Saving…' : 'Save preferences'))),
        const SizedBox(height: 22),
        const Text('Request a live FX quote', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        TextField(controller: amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.numbers), labelText: 'Amount')),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: DropdownButtonFormField<String>(initialValue: from, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'From'), items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => from = v ?? from))),
          const SizedBox(width: 10),
          const Icon(Icons.swap_horiz_rounded),
          const SizedBox(width: 10),
          Expanded(child: DropdownButtonFormField<String>(initialValue: to, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'To'), items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => to = v ?? to))),
        ]),
        const SizedBox(height: 10),
        SizedBox(height: 52, child: OutlinedButton.icon(onPressed: _quote, icon: const Icon(Icons.request_quote_outlined), label: const Text('Request provider/backend quote'))),
        const SizedBox(height: 12),
        const Card(child: Padding(padding: EdgeInsets.all(14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.lock_outline), SizedBox(width: 10), Expanded(child: Text('SwipeBuy does not invent or guarantee FX rates on the client. A production quote should include the rate, fee, timestamp, expiry and provider reference from your trusted payment/FX backend.', style: TextStyle(color: Colors.white70, height: 1.4)))]))),
        const SizedBox(height: 20),
        const Text('Recent quote requests', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        StreamBuilder(stream: service.recentQuotes(), builder: (context, snapshot) {
          if (snapshot.hasError) return Text(snapshot.error.toString());
          if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Card(child: ListTile(title: Text('No FX requests yet'), subtitle: Text('Request a quote above when you need a cross-border price.')));
          return Column(children: docs.map((d) { final x = d.data(); return Card(child: ListTile(leading: const Icon(Icons.receipt_long_outlined), title: Text('${x['amount'] ?? ''} ${x['fromCurrency'] ?? ''} → ${x['toCurrency'] ?? ''}'), subtitle: Text('Status: ${x['status'] ?? 'requested'}'))); }).toList());
        }),
      ]),
    );
  }
}
