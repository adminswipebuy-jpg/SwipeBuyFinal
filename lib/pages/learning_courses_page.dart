import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/learning_course_service.dart';

class LearningCoursesPage extends StatefulWidget {
  const LearningCoursesPage({super.key});
  @override State<LearningCoursesPage> createState() => _LearningCoursesPageState();
}

class _LearningCoursesPageState extends State<LearningCoursesPage> with SingleTickerProviderStateMixin {
  late final TabController tabs = TabController(length: 3, vsync: this);
  final service = LearningCourseService();

  @override
  void dispose() { tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Courses & Certification 2.0', style: TextStyle(fontWeight: FontWeight.w900)),
      bottom: TabBar(controller: tabs, tabs: const [Tab(text: 'Discover'), Tab(text: 'My Learning'), Tab(text: 'Publish')]),
    ),
    body: TabBarView(controller: tabs, children: [_discover(), _learning(), _publish()]),
  );

  Widget _discover() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: service.publishedCourses(),
    builder: (_, snap) {
      if (snap.hasError) return const Center(child: Text('Unable to load courses right now.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return const _Empty(icon: Icons.school_outlined, title: 'No courses yet', subtitle: 'Creators can publish structured courses, lessons and certification pathways.');
      return ListView.separated(
        padding: const EdgeInsets.all(16), itemCount: docs.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final d = docs[i].data();
          return Card(color: const Color(0xFF111720), child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const CircleAvatar(child: Icon(Icons.school_outlined)), const SizedBox(width: 12), Expanded(child: Text(d['title']?.toString() ?? 'Course', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))) ]),
              const SizedBox(height: 8),
              Text('${d['level'] ?? 'All levels'} • ${d['lessons'] ?? 0} lessons • ${d['duration'] ?? 'Self-paced'}', style: const TextStyle(color: Colors.white60)),
              const SizedBox(height: 6),
              Text(d['description']?.toString() ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 10),
              Row(children: [Expanded(child: Text(d['priceLabel']?.toString() ?? 'Enrollment', style: const TextStyle(fontWeight: FontWeight.w900))), FilledButton(onPressed: () => _enroll(docs[i].id), child: const Text('Enroll'))]),
            ]),
          ));
        },
      );
    },
  );

  Widget _learning() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: service.myEnrollments(),
    builder: (_, snap) {
      if (snap.hasError) return const Center(child: Text('Unable to load your learning area.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return const _Empty(icon: Icons.menu_book_outlined, title: 'Start learning', subtitle: 'Your enrolled courses, progress and certificates will appear here.');
      return ListView.separated(
        padding: const EdgeInsets.all(16), itemCount: docs.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final d = docs[i].data();
          final progress = ((d['progressPercent'] as num?)?.toInt() ?? 0).clamp(0, 100);
          final complete = progress >= 100;
          return Card(color: const Color(0xFF111720), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d['courseTitle']?.toString() ?? 'Course', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress / 100),
            const SizedBox(height: 6),
            Row(children: [Expanded(child: Text('$progress% complete • ${d['status'] ?? 'enrolled'}', style: const TextStyle(color: Colors.white60))), if (complete) OutlinedButton(onPressed: () => service.requestCertificate(enrollmentId: docs[i].id), child: const Text('Request certificate'))]),
            if (!complete) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => service.updateProgress(enrollmentId: docs[i].id, percent: (progress + 10).clamp(0, 100)), child: const Text('Mark next lesson complete'))),
          ])));
        },
      );
    },
  );

  Widget _publish() => ListView(padding: const EdgeInsets.all(18), children: const [
    Text('Publish a course', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
    SizedBox(height: 8),
    Text('Build structured learning experiences with lessons, quizzes, completion tracking and certificates. Enrollment, payments, content access and certificate issuance should be verified by trusted backend services.', style: TextStyle(color: Colors.white54)),
    SizedBox(height: 18),
    _Info(icon: Icons.video_library_outlined, title: 'Lessons & modules', subtitle: 'Organize videos, documents, quizzes and practical exercises.'),
    _Info(icon: Icons.verified_outlined, title: 'Certificates', subtitle: 'Issue completion certificates after verified course requirements.'),
    _Info(icon: Icons.analytics_outlined, title: 'Learning analytics', subtitle: 'Track enrollment, completion and learner engagement through backend reporting.'),
  ]);

  Future<void> _enroll(String id) async {
    await service.requestEnrollment(courseId: id);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enrollment request saved for secure processing.')));
  }
}

class _Info extends StatelessWidget { final IconData icon; final String title, subtitle; const _Info({required this.icon, required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Card(color: const Color(0xFF111720), child: ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle))); }
class _Empty extends StatelessWidget { final IconData icon; final String title, subtitle; const _Empty({required this.icon, required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 58, color: Colors.white30), const SizedBox(height: 14), Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54))]))); }
