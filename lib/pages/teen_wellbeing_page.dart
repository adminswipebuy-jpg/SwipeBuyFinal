import 'package:flutter/material.dart';
import '../services/teen_wellbeing_service.dart';

class TeenWellbeingPage extends StatefulWidget {
  const TeenWellbeingPage({super.key});

  @override
  State<TeenWellbeingPage> createState() => _TeenWellbeingPageState();
}

class _TeenWellbeingPageState extends State<TeenWellbeingPage> {
  final service = TeenWellbeingService();
  bool breakReminders = true;
  bool saferRecommendations = true;
  bool quietNotifications = false;
  bool reducedSocialPressure = true;
  bool busy = false;

  Future<void> _save() async {
    setState(() => busy = true);
    try {
      await service.saveControls(
        breakReminders: breakReminders,
        saferRecommendations: saferRecommendations,
        quietNotifications: quietNotifications,
        reducedSocialPressure: reducedSocialPressure,
      );
      await service.recordWellbeingAction('controls_saved');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wellbeing settings saved.')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _review() async {
    setState(() => busy = true);
    try {
      await service.requestWellbeingReview('User requested a wellbeing and recommendation safety review');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wellbeing review requested.')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Teen Wellbeing 2.0')),
        body: StreamBuilder<Map<String, dynamic>?>(
          stream: service.watchMine(),
          builder: (context, snapshot) {
            final data = snapshot.data;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('A calmer, safer SwipeBuy experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      SizedBox(height: 8),
                      Text('These controls help reduce recommendation pressure, unwanted interruptions and excessive engagement. They are preferences, not medical advice or guarantees.'),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(children: [
                    SwitchListTile(
                      title: const Text('Take-a-break reminders'),
                      subtitle: const Text('Prompt optional breaks during extended sessions.'),
                      value: breakReminders,
                      onChanged: busy ? null : (v) => setState(() => breakReminders = v),
                    ),
                    SwitchListTile(
                      title: const Text('Safer recommendations'),
                      subtitle: const Text('Prefer age-appropriate, lower-risk discovery signals.'),
                      value: saferRecommendations,
                      onChanged: busy ? null : (v) => setState(() => saferRecommendations = v),
                    ),
                    SwitchListTile(
                      title: const Text('Quiet notifications'),
                      subtitle: const Text('Reduce non-essential notification interruptions.'),
                      value: quietNotifications,
                      onChanged: busy ? null : (v) => setState(() => quietNotifications = v),
                    ),
                    SwitchListTile(
                      title: const Text('Reduce social-pressure signals'),
                      subtitle: const Text('Reduce prompts designed to encourage repeated engagement.'),
                      value: reducedSocialPressure,
                      onChanged: busy ? null : (v) => setState(() => reducedSocialPressure = v),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: FilledButton.icon(
                        onPressed: busy ? null : _save,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save wellbeing settings'),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.tune_outlined),
                    title: const Text('Current backend profile'),
                    subtitle: Text('Safer recommendations: ${(data?['saferRecommendations'] ?? saferRecommendations) ? 'on' : 'off'}\nBreak reminders: ${(data?['breakReminders'] ?? breakReminders) ? 'on' : 'off'}'),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Wellbeing review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      const Text('Request a trusted backend review of recommendation safety, notification intensity or account protections.'),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: busy ? null : _review,
                        icon: const Icon(Icons.health_and_safety_outlined),
                        label: const Text('Request wellbeing review'),
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      );
}
