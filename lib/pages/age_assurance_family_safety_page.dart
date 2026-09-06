import 'package:flutter/material.dart';
import '../services/age_safety_service.dart';

class AgeAssuranceFamilySafetyPage extends StatefulWidget {
  const AgeAssuranceFamilySafetyPage({super.key});

  @override
  State<AgeAssuranceFamilySafetyPage> createState() => _AgeAssuranceFamilySafetyPageState();
}

class _AgeAssuranceFamilySafetyPageState extends State<AgeAssuranceFamilySafetyPage> {
  final service = AgeSafetyService();
  bool restrictedContent = true;
  bool discoverability = false;
  bool directMessages = false;
  bool busy = false;

  Future<void> _savePreferences() async {
    setState(() => busy = true);
    try {
      await service.saveSafetyPreferences(
        restrictedContent: restrictedContent,
        discoverability: discoverability,
        directMessages: directMessages,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Safety preferences saved.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _requestAgeReview() async {
    setState(() => busy = true);
    try {
      await service.requestAgeAssuranceReview(reason: 'User requested age assurance or correction');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Age-assurance review requested.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _requestFamilyLink() async {
    setState(() => busy = true);
    try {
      await service.requestFamilyLink(reason: 'User requested family safety connection');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Family-safety request submitted.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Age & Family Safety 2.0')),
        body: StreamBuilder<Map<String, dynamic>?>(
          stream: service.watchMine(),
          builder: (context, snapshot) {
            final data = snapshot.data;
            final status = (data?['status'] ?? 'Backend age assurance not completed').toString();
            final band = (data?['ageBand'] ?? 'Not classified').toString();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.family_restroom_outlined),
                    title: const Text('Safer experiences for younger users'),
                    subtitle: Text('Age status: $status\nAge band: $band'),
                  ),
                ),
                const SizedBox(height: 12),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Protection layers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      SizedBox(height: 8),
                      Text('Age assurance, age-appropriate content, safer messaging, discoverability limits, reporting and family-safety connections should be enforced by trusted backend systems.'),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(children: [
                    SwitchListTile(
                      title: const Text('Restrict mature content'),
                      subtitle: const Text('Prefer safer recommendations and content filters.'),
                      value: restrictedContent,
                      onChanged: busy ? null : (v) => setState(() => restrictedContent = v),
                    ),
                    SwitchListTile(
                      title: const Text('Limit profile discoverability'),
                      subtitle: const Text('Reduce exposure to people outside your trusted network.'),
                      value: !discoverability,
                      onChanged: busy ? null : (v) => setState(() => discoverability = !v),
                    ),
                    SwitchListTile(
                      title: const Text('Restrict direct messages'),
                      subtitle: const Text('Limit unsolicited messaging from unknown accounts.'),
                      value: !directMessages,
                      onChanged: busy ? null : (v) => setState(() => directMessages = !v),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: FilledButton.icon(
                        onPressed: busy ? null : _savePreferences,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save safety preferences'),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Age assurance review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      const Text('Use a protected backend review flow for age-band corrections or verification. Do not enter identity documents into this client page.'),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: busy ? null : _requestAgeReview,
                        icon: const Icon(Icons.verified_user_outlined),
                        label: const Text('Request age review'),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Family safety connection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      const Text('Request a protected family-safety connection. Consent, eligibility, account linking and controls must be verified by backend services.'),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: busy ? null : _requestFamilyLink,
                        icon: const Icon(Icons.link_outlined),
                        label: const Text('Request family connection'),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      );
}
