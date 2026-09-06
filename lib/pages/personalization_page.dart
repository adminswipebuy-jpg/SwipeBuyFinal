import 'package:flutter/material.dart';
import '../services/personalization_service.dart';

class PersonalizationPage extends StatefulWidget {
  const PersonalizationPage({super.key});
  @override
  State<PersonalizationPage> createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage> {
  final service = PersonalizationService();
  final location = TextEditingController();
  String language = 'English';
  bool showNearby = true;
  final selected = <String>{};
  bool busy = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await service.loadPreferences();
    selected.addAll(((p['interests'] as List?) ?? const []).map((e) => e.toString()));
    location.text = (p['location'] ?? 'Worldwide').toString();
    language = (p['language'] ?? 'English').toString();
    showNearby = p['showNearby'] != false;
    if (mounted) setState(() => busy = false);
  }

  Future<void> _save() async {
    setState(() => busy = true);
    await service.savePreferences(
      interests: selected.toList(),
      location: location.text,
      language: language,
      showNearby: showNearby,
    );
    if (mounted) {
      setState(() => busy = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your For You feed preferences were saved.')));
    }
  }

  Future<void> _reset() async {
    await service.resetRecommendations();
    selected.clear();
    if (mounted) setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recommendation preferences reset.')));
  }

  @override
  Widget build(BuildContext context) {
    const interests = PersonalizationService.defaultInterests;
    return Scaffold(
      appBar: AppBar(title: const Text('For You preferences')),
      body: busy && selected.isEmpty && location.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                const Text('Teach SwipeBuy what you want to see', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('Choose interests, location and nearby content controls. You can change these anytime.'),
                const SizedBox(height: 22),
                TextField(
                  controller: location,
                  decoration: InputDecoration(labelText: 'Home / preferred location', hintText: 'e.g. Wa, Ghana', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: language,
                  decoration: InputDecoration(labelText: 'Content language', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                  items: const ['English', 'French', 'Arabic', 'Spanish'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
                  onChanged: (v) => setState(() => language = v ?? 'English'),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Prioritize nearby content'),
                  subtitle: const Text('Show more relevant local jobs, businesses, events and services.'),
                  value: showNearby,
                  onChanged: (v) => setState(() => showNearby = v),
                ),
                const SizedBox(height: 10),
                const Text('Your interests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interests.map((x) => FilterChip(
                    label: Text(x),
                    selected: selected.contains(x),
                    onSelected: (v) => setState(() => v ? selected.add(x) : selected.remove(x)),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(height: 52, child: FilledButton(onPressed: busy ? null : _save, child: Text(busy ? 'Saving...' : 'Save preferences'))),
                const SizedBox(height: 8),
                TextButton(onPressed: busy ? null : _reset, child: const Text('Reset my recommendations')),
              ],
            ),
    );
  }
}
