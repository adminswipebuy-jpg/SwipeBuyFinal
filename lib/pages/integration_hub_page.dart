import 'package:flutter/material.dart';

import 'ai_command_center_2_page.dart';
import 'marketplace_v2_page.dart';
import 'global_services_marketplace_page.dart';
import 'professional_network_page.dart';
import 'learning_courses_page.dart';
import 'creator_events_commerce_page.dart';
import 'global_logistics_page.dart';
import 'notifications_page.dart';
import 'safety_center_page.dart';
import 'privacy_center_page.dart';
import 'global_identity_verification_page.dart';
import 'platform_observability_page.dart';
import 'platform_resilience_page.dart';
import 'release_readiness_page.dart';
import 'core_flow_audit_page.dart';

class IntegrationHubPage extends StatelessWidget {
  const IntegrationHubPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _section(BuildContext context, String title, List<_HubItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
          child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                ListTile(
                  leading: CircleAvatar(child: Icon(items[i].icon, size: 20)),
                  title: Text(items[i].title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(items[i].subtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _open(context, items[i].page),
                ),
                if (i != items.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SwipeBuy Integration Hub')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
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
                Text('Connect the pieces', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text('Use this hub to move between the major SwipeBuy journeys and verify that each feature has a clear destination.'),
              ],
            ),
          ),
          _section(context, 'Core journeys', [
            _HubItem('Marketplace & checkout', 'Buy products and manage commerce flows', Icons.shopping_bag_outlined, const MarketplaceV2Page()),
            _HubItem('Professional services', 'Discover, hire and book professionals', Icons.handyman_outlined, const GlobalServicesMarketplacePage()),
            _HubItem('Professional network', 'Network, communities and opportunities', Icons.groups_2_outlined, const ProfessionalNetworkPage()),
            _HubItem('Learning', 'Courses, enrollment and certification', Icons.school_outlined, const LearningCoursesPage()),
            _HubItem('Creator commerce', 'Creator events, tickets and fan commerce', Icons.event_available_outlined, const CreatorEventsCommercePage()),
            _HubItem('Logistics', 'Delivery, shipping and tracking', Icons.local_shipping_outlined, const GlobalLogisticsPage()),
          ]),
          _section(context, 'AI & user experience', [
            _HubItem('AI command center', 'AI discovery, voice, vision and actions', Icons.auto_awesome_outlined, const AiCommandCenter2Page()),
            _HubItem('Notifications', 'Push, realtime and notification controls', Icons.notifications_none_outlined, const NotificationsPage()),
          ]),
          _section(context, 'Trust & platform', [
            _HubItem('Safety center', 'Reports, abuse prevention and safety tools', Icons.shield_outlined, const SafetyCenterPage()),
            _HubItem('Privacy center', 'Data controls and privacy requests', Icons.lock_outline, const PrivacyCenterPage()),
            _HubItem('Identity verification', 'Personal, business and professional verification', Icons.verified_user_outlined, const GlobalIdentityVerificationPage()),
            _HubItem('Observability', 'Platform health and performance monitoring', Icons.monitor_heart_outlined, const PlatformObservabilityPage()),
            _HubItem('Resilience', 'Backup, recovery and continuity workflows', Icons.health_and_safety_outlined, const PlatformResiliencePage()),
          ]),
          _section(context, 'Release', [
            _HubItem('Core flow audit', 'Walk the critical journeys before V15', Icons.alt_route_rounded, const CoreFlowAuditPage()),
            _HubItem('Release readiness', 'Track blockers before V15', Icons.rocket_launch_outlined, const ReleaseReadinessPage()),
          ]),
        ],
      ),
    );
  }
}

class _HubItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
  const _HubItem(this.title, this.subtitle, this.icon, this.page);
}
