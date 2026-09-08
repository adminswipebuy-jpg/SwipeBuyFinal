import 'package:flutter/material.dart';
import '../services/ai_adaptive_personalization_service.dart';

class AiAdaptivePersonalizationPage extends StatefulWidget {
  const AiAdaptivePersonalizationPage({super.key});

  @override
  State<AiAdaptivePersonalizationPage> createState() =>
      _AiAdaptivePersonalizationPageState();
}

class _AiAdaptivePersonalizationPageState
    extends State<AiAdaptivePersonalizationPage> {
  final _service = AiAdaptivePersonalizationService();
  final _category = TextEditingController();

  String _signal = 'view';
  Future<Map<String, double>>? _profile;

  @override
  void initState() {
    super.initState();
    _profile = _service.buildCategoryProfile();
  }

  @override
  void dispose() {
    _category.dispose();
    super.dispose();
  }

  Future<void> _record() async {
    final category = _category.text.trim();

    if (category.isEmpty) return;

    await _service.recordSignal(
      type: _signal,
      category: category,
      weight: _weightFor(_signal),
    );

    if (mounted) {
      _category.clear();

      setState(() {
        _profile = _service.buildCategoryProfile();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Learning signal saved.'),
        ),
      );
    }
  }

  double _weightFor(String signal) => switch (signal) {
        'save' => 4,
        'purchase' => 7,
        'book' => 7,
        'follow' => 5,
        'like' => 3,
        'view' => 1,
        'not_interested' => -5,
        _ => 1,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Learning & Personalization 2.0'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _hero(),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Teach SwipeBuy what matters to you',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Signals are private to your account and can help improve '
                    'recommendations. They do not complete purchases or bookings.',
                    style: TextStyle(
                      color: Colors.white60,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: _signal,
                    items: const [
                      DropdownMenuItem(
                        value: 'view',
                        child: Text('View'),
                      ),
                      DropdownMenuItem(
                        value: 'like',
                        child: Text('Like'),
                      ),
                      DropdownMenuItem(
                        value: 'save',
                        child: Text('Save'),
                      ),
                      DropdownMenuItem(
                        value: 'follow',
                        child: Text('Follow'),
                      ),
                      DropdownMenuItem(
                        value: 'book',
                        child: Text('Book'),
                      ),
                      DropdownMenuItem(
                        value: 'purchase',
                        child: Text('Purchase'),
                      ),
                      DropdownMenuItem(
                        value: 'not_interested',
                        child: Text('Not interested'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _signal = value ?? 'view';
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Interaction',
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      hintText: 'e.g. Electronics, Jobs, Travel',
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _record,
                      icon: const Icon(Icons.psychology_outlined),
                      label: const Text('Record learning signal'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Your adaptive interests',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          FutureBuilder<Map<String, double>>(
            future: _profile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final entries =
                  (snapshot.data ?? {}).entries.toList()
                    ..sort(
                      (a, b) => b.value.compareTo(a.value),
                    );

              if (entries.isEmpty) {
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.insights_outlined),
                    title: Text('Not enough signals yet'),
                    subtitle: Text(
                      'Explore SwipeBuy and your profile will adapt over time.',
                    ),
                  ),
                );
              }

              return Column(
                children: entries.take(8).map((entry) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.trending_up),
                      title: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      trailing: Text(
                        entry.value.toStringAsFixed(0),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                child: Icon(Icons.auto_awesome),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Adaptive SwipeBuy AI',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Recommendations can improve from signals such as views, likes, '
            'saves, follows, purchases and “not interested”. The production '
            'ranking layer should remain server-controlled.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}