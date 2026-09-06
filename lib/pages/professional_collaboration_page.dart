import 'package:flutter/material.dart';
import '../services/professional_collaboration_service.dart';

class ProfessionalCollaborationPage extends StatefulWidget {
  const ProfessionalCollaborationPage({super.key});
  @override
  State<ProfessionalCollaborationPage> createState() => _ProfessionalCollaborationPageState();
}

class _ProfessionalCollaborationPageState extends State<ProfessionalCollaborationPage> {
  String filter = 'All';
  String status = 'Choose a workspace to collaborate.';

  @override
  Widget build(BuildContext context) {
    final all = ProfessionalCollaborationService.instance.demoProjects();
    final items = filter == 'All' ? all : all.where((p) => p.status == filter).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Collaboration 2.0')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newWorkspace,
        icon: const Icon(Icons.add),
        label: const Text('New workspace'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          const Text('Work together. Deliver faster.', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Project rooms for professionals, clients, teams and freelancers.', style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, children: ['All', 'Active', 'Planning'].map((x) => ChoiceChip(label: Text(x), selected: filter == x, onSelected: (_) => setState(() => filter = x))).toList()),
          const SizedBox(height: 14),
          ...items.map(_card),
          const SizedBox(height: 8),
          Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(status))),
          const SizedBox(height: 8),
          const Text('Production architecture: permissions, files, payments, client approvals and external submissions should be enforced by backend authorization.', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _card(CollaborationProject project) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(project.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), Chip(label: Text(project.status))]),
        Text('${project.organization} • ${project.members} members', style: const TextStyle(color: Colors.white60)),
        const SizedBox(height: 6),
        Text(project.summary),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => _openDetails(project), icon: const Icon(Icons.dashboard_outlined), label: const Text('Workspace'))),
          const SizedBox(width: 8),
          Expanded(child: FilledButton.icon(onPressed: () async { await ProfessionalCollaborationService.instance.requestJoin(project); if (mounted) setState(() => status = 'Join request prepared for ${project.title}.'); }, icon: const Icon(Icons.group_add_outlined), label: const Text('Join'))),
        ]),
      ]),
    ),
  );

  void _openDetails(CollaborationProject project) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CollaborationWorkspacePage(project: project)));
  }

  Future<void> _newWorkspace() async {
    final title = TextEditingController();
    final description = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('New workspace'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, decoration: const InputDecoration(labelText: 'Project title')), const SizedBox(height: 10), TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description'))]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, title.text.trim().isNotEmpty), child: const Text('Create'))],
    ));
    if (ok != true) return;
    await ProfessionalCollaborationService.instance.createWorkspace(title: title.text, description: description.text);
    if (mounted) setState(() => status = 'Workspace creation request submitted.');
  }
}

class CollaborationWorkspacePage extends StatelessWidget {
  final CollaborationProject project;
  const CollaborationWorkspacePage({super.key, required this.project});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(project.title)),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      _tile(Icons.task_alt, 'Tasks', 'Assign deliverables and track progress.'),
      _tile(Icons.chat_bubble_outline, 'Project chat', 'Coordinate decisions and handoffs.'),
      _tile(Icons.folder_open, 'Files', 'Centralize project files and versions.'),
      _tile(Icons.fact_check_outlined, 'Approvals', 'Request client or team sign-off.'),
      _tile(Icons.receipt_long_outlined, 'Contracts & payments', 'Connect approved work to backend-controlled billing.'),
      _tile(Icons.timeline_outlined, 'Timeline', 'Plan milestones and delivery dates.'),
    ]),
  );

  Widget _tile(IconData icon, String title, String text) => Card(child: ListTile(leading: Icon(icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(text)));
}
