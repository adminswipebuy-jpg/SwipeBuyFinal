import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class LocalizationRegionalExperiencePage extends StatefulWidget {
  final LocalizationService service;
  const LocalizationRegionalExperiencePage({super.key, required this.service});

  @override
  State<LocalizationRegionalExperiencePage> createState() => _LocalizationRegionalExperiencePageState();
}

class _LocalizationRegionalExperiencePageState extends State<LocalizationRegionalExperiencePage> {
  late LocalizationPreferences prefs;
  @override
  void initState() { super.initState(); prefs = widget.service.preferences; }

  Future<void> _save() async {
    await widget.service.updatePreferences(prefs);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Regional preferences saved')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Language & Region')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('SwipeBuy V13.12', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(value: prefs.locale.languageCode, decoration: const InputDecoration(labelText: 'Language'), items: const [
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'fr', child: Text('Français')),
        DropdownMenuItem(value: 'es', child: Text('Español')),
      ], onChanged: (v) => setState(() => prefs = prefs.copyWith(locale: Locale(v!)))),
      DropdownButtonFormField<String>(value: prefs.countryCode, decoration: const InputDecoration(labelText: 'Country / region'), items: const [
        DropdownMenuItem(value: 'GH', child: Text('Ghana')),
        DropdownMenuItem(value: 'US', child: Text('United States')),
        DropdownMenuItem(value: 'GB', child: Text('United Kingdom')),
      ], onChanged: (v) => setState(() => prefs = prefs.copyWith(countryCode: v!))),
      DropdownButtonFormField<String>(value: prefs.currencyCode, decoration: const InputDecoration(labelText: 'Display currency'), items: const [
        DropdownMenuItem(value: 'GHS', child: Text('Ghana cedi (GHS)')),
        DropdownMenuItem(value: 'USD', child: Text('US dollar (USD)')),
        DropdownMenuItem(value: 'EUR', child: Text('Euro (EUR)')),
        DropdownMenuItem(value: 'GBP', child: Text('British pound (GBP)')),
      ], onChanged: (v) => setState(() => prefs = prefs.copyWith(currencyCode: v!))),
      SwitchListTile(title: const Text('24-hour time'), value: prefs.use24HourTime, onChanged: (v) => setState(() => prefs = prefs.copyWith(use24HourTime: v))),
      SwitchListTile(title: const Text('Metric measurements'), value: prefs.metricUnits, onChanged: (v) => setState(() => prefs = prefs.copyWith(metricUnits: v))),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: _save, child: const Text('Save preferences')),
      const SizedBox(height: 12),
      Text('Preview: ${widget.service.formatCurrency(125.50)}', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      const Text('Payment settlement, taxes, exchange rates, eligibility and legal requirements remain backend/provider controlled.'),
    ]),
  );
}
