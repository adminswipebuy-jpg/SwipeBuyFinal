import 'package:flutter/material.dart';

import 'marketplace_v2_page.dart';
import 'professional_booking_page.dart';
import 'professional_network_page.dart';
import 'learning_courses_page.dart';
import 'creator_studio_page.dart';
import 'global_logistics_page.dart';
import 'global_services_marketplace_page.dart';
import 'ai_assistant_workspace_page.dart';
import 'release_readiness_page.dart';
import 'v15_release_gate_page.dart';
import 'final_integration_checklist_page.dart';

class CoreFlowAuditPage extends StatelessWidget {
  const CoreFlowAuditPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final flows = <_FlowItem>[
      _FlowItem('Discover & shop', 'Browse → product → checkout', Icons.shopping_bag_outlined, 'UI wired', const MarketplaceV2Page()),
      _FlowItem('Hire & book', 'Find professional → booking', Icons.handyman_outlined, 'UI wired', const ProfessionalBookingPage()),
      _FlowItem('Professional network', 'Profile → network → opportunity', Icons.groups_2_outlined, 'UI wired', const ProfessionalNetworkPage()),
      _FlowItem('Learn', 'Course → enrollment → progress', Icons.school_outlined, 'UI wired', const LearningCoursesPage()),
      _FlowItem('Create & publish', 'Create → media → publish', Icons.video_camera_back_outlined, 'Provider check', const CreatorStudioPage()),
      _FlowItem('Deliver & track', 'Order → delivery → tracking', Icons.local_shipping_outlined, 'Backend check', const GlobalLogisticsPage()),
      _FlowItem('Services marketplace', 'Discover service → hire', Icons.work_outline, 'UI wired', const GlobalServicesMarketplacePage()),
      _FlowItem('AI assistant', 'Ask → action → confirmation', Icons.auto_awesome_outlined, 'Backend/provider check', const AiAssistantWorkspacePage()),
      _FlowItem('Release gate', 'Blockers → verification → V15', Icons.rocket_launch_outlined, 'Final gate', const ReleaseReadinessPage()),
      _FlowItem('V15 release checklist', 'Production integrations → device tests → release', Icons.fact_check_outlined, 'Final gate', const V15ReleaseGatePage()),
      _FlowItem('Final integration checklist', 'Close remaining environment and QA blockers', Icons.rule_rounded, 'Release prep', const FinalIntegrationChecklistPage()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Core Flow Audit')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(colors: [Color(0xFF14231F), Color(0xFF101720)]),
              border: Border.all(color: Color(0x2238D9A9)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Finish the journeys, not the feature list', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text('Use this screen as the V15 integration checklist. “UI wired” means the screen is reachable; backend/provider work still needs real testing.'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final flow in flows)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                leading: CircleAvatar(child: Icon(flow.icon, size: 20)),
                title: Text(flow.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(flow.subtitle),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(flow.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right_rounded, size: 20),
                  ],
                ),
                onTap: () => _open(context, flow.page),
              ),
            ),
        ],
      ),
    );
  }
}

class _FlowItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String status;
  final Widget page;
  const _FlowItem(this.title, this.subtitle, this.icon, this.status, this.page);
}
