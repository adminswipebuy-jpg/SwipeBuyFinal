import 'package:cloud_firestore/cloud_firestore.dart';

class CollaborationProject {
  final String id;
  final String title;
  final String organization;
  final String status;
  final String members;
  final String summary;
  const CollaborationProject({required this.id, required this.title, required this.organization, required this.status, required this.members, required this.summary});
}

class ProfessionalCollaborationService {
  ProfessionalCollaborationService._();
  static final instance = ProfessionalCollaborationService._();
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<CollaborationProject> demoProjects() => const [
    CollaborationProject(id: 'design-launch', title: 'Product Launch Team', organization: 'SwipeBuy Studio', status: 'Active', members: '8', summary: 'Coordinate design, marketing and launch deliverables in one workspace.'),
    CollaborationProject(id: 'growth-sprint', title: 'Growth Sprint', organization: 'Global Growth Network', status: 'Planning', members: '12', summary: 'Share tasks, updates and milestones for a cross-functional growth project.'),
    CollaborationProject(id: 'client-build', title: 'Client App Build', organization: 'Freelancer Collective', status: 'Active', members: '5', summary: 'Track project work, approvals and handoffs between client and professionals.'),
  ];

  Future<void> createWorkspace({required String title, required String description}) async {
    final user = db.app.options.appId;
    await db.collection('professional_workspaces').add({
      'title': title.trim(),
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'clientAppId': user,
      'status': 'requested',
    });
  }

  Future<void> requestJoin(CollaborationProject project) async {
    await db.collection('professional_workspace_join_requests').add({
      'workspaceId': project.id,
      'title': project.title,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'requested',
    });
  }
}
