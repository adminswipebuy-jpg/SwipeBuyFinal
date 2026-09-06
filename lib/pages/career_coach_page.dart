import 'package:flutter/material.dart';

class CareerCoachPage extends StatefulWidget {
  const CareerCoachPage({super.key});
  @override
  State<CareerCoachPage> createState() => _CareerCoachPageState();
}

class _CareerCoachPageState extends State<CareerCoachPage> {
  final skills = TextEditingController();
  final role = TextEditingController();
  final experience = TextEditingController();
  final cv = TextEditingController();
  bool _tailored = false;
  String _analysis = 'Add your target role and skills to generate a career plan.';

  @override
  void dispose() { skills.dispose(); role.dispose(); experience.dispose(); cv.dispose(); super.dispose(); }

  void _analyze() {
    final target = role.text.trim().isEmpty ? 'your target role' : role.text.trim();
    final skillText = skills.text.trim().isEmpty ? 'core skills' : skills.text.trim();
    setState(() {
      _analysis = 'For $target, strengthen $skillText, tailor your CV to measurable outcomes, and prioritize relevant jobs before applying.';
    });
  }

  void _tailorCv() {
    final target = role.text.trim().isEmpty ? 'the target role' : role.text.trim();
    setState(() {
      _tailored = true;
      cv.text = 'PROFESSIONAL SUMMARY\nResults-focused professional targeting $target.\n\nKEY SKILLS\n${skills.text.trim()}\n\nEXPERIENCE\n${experience.text.trim()}\n\nAPPLICATION NOTE\nHighlight measurable impact, relevant tools, and evidence aligned with the job description.';
    });
  }

  void _apply() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application request prepared. Final submission should be confirmed and completed by the backend/job provider.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI Career Coach 2.0')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Build your career faster', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      const Text('Career planning, CV tailoring and job-application assistance in one place.', style: TextStyle(color: Colors.white60)),
      const SizedBox(height: 18),
      _field(role, 'Target role', 'e.g. Software Developer'),
      const SizedBox(height: 10),
      _field(skills, 'Skills', 'Python, Flutter, sales, design...'),
      const SizedBox(height: 10),
      _field(experience, 'Experience', 'Briefly describe your experience', lines: 4),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _analyze, icon: const Icon(Icons.psychology_outlined), label: const Text('Analyze my career fit'))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Career intelligence', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text(_analysis)]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CV Builder', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _tailorCv, icon: const Icon(Icons.description_outlined), label: const Text('Tailor CV for target role'))),
        if (_tailored) ...[const SizedBox(height: 10), TextField(controller: cv, maxLines: 12, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Draft CV'))],
      ]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Job Application Assistant', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6), const Text('Prepare an application package and hand it off for explicit confirmation before submission.', style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _apply, icon: const Icon(Icons.send_outlined), label: const Text('Prepare job application'))),
      ]))),
      const SizedBox(height: 18),
      const Text('Safety: applications, external communications and submissions should be executed only after user confirmation and server-side validation.', style: TextStyle(color: Colors.white54, fontSize: 12)),
    ]),
  );

  Widget _field(TextEditingController controller, String label, String hint, {int lines = 1}) => TextField(controller: controller, maxLines: lines, decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()));
}
