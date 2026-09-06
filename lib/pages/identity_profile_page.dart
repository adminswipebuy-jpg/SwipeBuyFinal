import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/business_service.dart';
import 'communications_page.dart';
import 'creator_studio_page.dart';
import 'creator_profile_page.dart';
import 'creator_discovery_page.dart';
import 'monetization_page.dart';
import 'personalization_page.dart';
import 'safety_center_page.dart';
import 'wallet_page.dart';
import 'global_payments_page.dart';
import 'fx_commerce_page.dart';
import 'command_center_page.dart';
import 'analytics_page.dart';
import 'connections_page.dart';
import 'notifications_page.dart';
import 'ai_command_center_2_page.dart';
import 'ai_automation_page.dart';
import 'ai_agents_page.dart';
import 'ai_memory_page.dart';
import 'ai_proactive_assistant_page.dart';
import 'ai_real_world_actions_page.dart';
import 'ai_agent_marketplace_page.dart';
import 'ai_agent_trust_page.dart';
import 'ai_agent_platform_page.dart';
import 'merchant_operations_page.dart';
import 'business_crm_page.dart';
import 'marketing_growth_page.dart';
import 'business_ads_page.dart';
import 'creator_brand_partnerships_page.dart';
import 'creator_memberships_page.dart';
import 'global_creator_community_page.dart';
import 'community_events_page.dart';
import 'creator_events_commerce_page.dart';
import 'digital_products_page.dart';
import 'learning_courses_page.dart';
import 'career_coach_page.dart';
import 'freelancer_marketplace_page.dart';
import 'professional_network_page.dart';
import 'global_services_marketplace_page.dart';
import 'professional_payments_disputes_page.dart';
import 'professional_reputation_page.dart';
import 'professional_booking_page.dart';
import 'global_identity_verification_page.dart';
import 'platform_governance_page.dart';
import 'fraud_risk_security_page.dart';
import 'device_trust_security_page.dart';
import 'mfa_passkey_security_page.dart';
import 'privacy_center_page.dart';
import 'data_governance_page.dart';
import 'age_assurance_family_safety_page.dart';
import 'teen_wellbeing_page.dart';
import 'realtime_infrastructure_page.dart';
import 'integration_hub_page.dart';
import 'core_flow_audit_page.dart';

class IdentityProfilePage extends StatefulWidget {
  const IdentityProfilePage({super.key});
  @override
  State<IdentityProfilePage> createState() => _IdentityProfilePageState();
}

class _IdentityProfilePageState extends State<IdentityProfilePage> {
  String mode = 'Personal';
  final displayName = TextEditingController();
  final bio = TextEditingController();
  final username = TextEditingController();
  int get completeness {
    var score = 40;
    if (displayName.text.trim().length >= 3) score += 20;
    if (username.text.trim().length >= 3) score += 15;
    if (bio.text.trim().length >= 10) score += 15;
    if (mode != 'Personal') score += 10;
    return score.clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    displayName.text = AuthService.currentUser?.displayName ?? '';
    username.text = (AuthService.currentUser?.email ?? 'user').split('@').first;
    displayName.addListener(_refresh);
    bio.addListener(_refresh);
    username.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  void _open(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  void dispose() {
    displayName.dispose();
    bio.dispose();
    username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.currentUser?.uid ?? '';
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w900)),
            actions: [
              IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () => _open(const PersonalizationPage())),
              IconButton(icon: const Icon(Icons.shield_outlined), onPressed: () => _open(const SafetyCenterPage())),
            ],
          ),
          SliverToBoxAdapter(child: _hero()),
          SliverToBoxAdapter(child: _identitySwitcher()),
          SliverToBoxAdapter(child: _stats()),
          SliverToBoxAdapter(child: _tools()),
          SliverToBoxAdapter(child: _sections(uid)),
          SliverToBoxAdapter(child: const SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _hero() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(colors: [Color(0xFF16251F), Color(0xFF111720)]),
        border: Border.all(color: const Color(0xFF38D9A9).withOpacity(.15)),
      ),
      child: Column(children: [
        Row(children: [
          Stack(children: [
            const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 40)),
            Positioned(right: 0, bottom: 0, child: Container(width: 28, height: 28, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981)), child: const Icon(Icons.edit, size: 15))),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(displayName.text.isEmpty ? 'SwipeBuy User' : displayName.text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            Text('@${username.text.isEmpty ? 'username' : username.text}', style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 6),
            Text(mode, style: const TextStyle(color: Color(0xFF38D9A9), fontWeight: FontWeight.w800)),
          ])),
        ]),
        const SizedBox(height: 14),
        Text(bio.text.isEmpty ? 'Tell people what you create, sell, teach or do.' : bio.text, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Text('Profile strength', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white.withOpacity(.9)))),
          Text('$completeness%', style: const TextStyle(fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(minHeight: 8, value: completeness / 100)),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _editProfile, icon: const Icon(Icons.edit_outlined), label: const Text('Edit profile'))),
      ]),
    ),
  );

  Widget _identitySwitcher() => SizedBox(
    height: 56,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final values = ['Personal', 'Creator', 'Business', 'Professional'];
        final icons = [Icons.person_outline, Icons.movie_filter_outlined, Icons.storefront_outlined, Icons.badge_outlined];
        final active = mode == values[i];
        return ChoiceChip(label: Text(values[i]), avatar: Icon(icons[i], size: 17), selected: active, onSelected: (_) {
          setState(() => mode = values[i]);
        });
      },
    ),
  );

  Widget _stats() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
    child: Row(children: [
      _stat('Followers', '0'), _stat('Following', '0'), _stat('Posts', '0'), _stat('Reviews', '0'),
    ]),
  );

  Widget _stat(String label, String value) => Expanded(child: Column(children: [Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12))]));

  Widget _tools() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Your tools', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _tool('Command Center', Icons.dashboard_customize_outlined, const Color(0xFF38D9A9), () => _open(const CommandCenterPage()))),
        const SizedBox(width: 9),
        Expanded(child: _tool('Creator Studio', Icons.video_library_outlined, Colors.orange, () => _open(const CreatorStudioPage()))),
        const SizedBox(width: 9),
        Expanded(child: _tool('Monetize', Icons.monetization_on_outlined, Colors.amber, () => _open(const MonetizationPage()))),
      ]),
    ],),
  );

  Widget _tool(String label, IconData icon, Color color, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF111720), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)), child: Column(children: [Icon(icon, color: color), const SizedBox(height: 6), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))])),
  );

  Widget _sections(String uid) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
    child: Card(
      color: const Color(0xFF111720),
      child: Column(children: [
        ListTile(leading: const Icon(Icons.people_alt_outlined), title: const Text('Connections'), subtitle: const Text('Followers, following and people discovery'), onTap: () => _open(const ConnectionsPage())),
        ListTile(leading: const Icon(Icons.explore_outlined), title: const Text('Discover creators'), subtitle: const Text('Find creators by topic, audience and category'), onTap: () => _open(const CreatorDiscoveryPage())),
        ListTile(leading: const Icon(Icons.notifications_none_outlined), title: const Text('Notifications'), subtitle: const Text('Activity and notification preferences'), onTap: () => _open(const NotificationsPage())),
        ListTile(leading: const Icon(Icons.auto_awesome_outlined), title: const Text('Notification Intelligence 2.0'), subtitle: const Text('Realtime events, personalized priority and digests'), onTap: () => _open(const NotificationIntelligencePage())),
        ListTile(leading: const Icon(Icons.forum_outlined), title: const Text('Communities & chats'), subtitle: const Text('Conversations and communities'), onTap: () => _open(const CommunicationsPage())),
        ListTile(leading: const Icon(Icons.storefront_outlined), title: const Text('Business identity'), subtitle: const Text('Storefront, orders and business analytics'), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Business dashboard is available from your business workspace.')))),
        ListTile(leading: const Icon(Icons.settings_suggest_outlined), title: const Text('Merchant Operations 2.0'), subtitle: const Text('Inventory, fulfillment, returns and team workflows'), onTap: () => _open(const MerchantOperationsPage())),
        ListTile(leading: const Icon(Icons.insights_outlined), title: const Text('Business CRM & Customer Intelligence 2.0'), subtitle: const Text('Customer 360, segments, retention signals and outreach workflows'), onTap: () => _open(const BusinessCrmPage())),
        ListTile(leading: const Icon(Icons.campaign_outlined), title: const Text('Marketing & Growth Intelligence 2.0'), subtitle: const Text('Campaigns, audiences, attribution and growth workflows'), onTap: () => _open(const MarketingGrowthPage())),
        ListTile(leading: const Icon(Icons.ads_click_outlined), title: const Text('Business Ads Platform 2.0'), subtitle: const Text('Campaigns, placements, audiences, budgets and ad analytics'), onTap: () => _open(const BusinessAdsPage())),
        ListTile(leading: const Icon(Icons.handshake_outlined), title: const Text('Creator Brand Partnerships 2.0'), subtitle: const Text('Sponsored content, proposals, disclosures and brand workflows'), onTap: () => _open(const CreatorBrandPartnershipsPage())),
        ListTile(leading: const Icon(Icons.workspace_premium_outlined), title: const Text('Creator Memberships 2.0'), subtitle: const Text('Premium plans, fan perks, memberships and creator earnings'), onTap: () => _open(const CreatorMembershipsPage())),
        ListTile(leading: const Icon(Icons.diversity_3_outlined), title: const Text('Global Creator & Community 1.0'), subtitle: const Text('Communities, creator hubs and global audience spaces'), onTap: () => _open(const GlobalCreatorCommunityPage())),
        ListTile(leading: const Icon(Icons.event_available_outlined), title: const Text('Community Events & LIVE 2.0'), subtitle: const Text('Events, LIVE groups and creator fan experiences'), onTap: () => _open(const CommunityEventsPage())),
        ListTile(leading: const Icon(Icons.confirmation_num_outlined), title: const Text('Creator Events & Fan Commerce 2.0'), subtitle: const Text('Ticketing, fan shop, bundles and creator event commerce'), onTap: () => _open(const CreatorEventsCommercePage())),
        ListTile(leading: const Icon(Icons.file_download_outlined), title: const Text('Digital Products & Downloads 2.0'), subtitle: const Text('Courses, templates, ebooks, presets and verified creator downloads'), onTap: () => _open(const DigitalProductsPage())),
        ListTile(leading: const Icon(Icons.school_outlined), title: const Text('Courses & Certification 2.0'), subtitle: const Text('Structured learning, progress tracking and certificates'), onTap: () => _open(const LearningCoursesPage())),
        ListTile(leading: const Icon(Icons.work_outline), title: const Text('AI Career Coach & CV Assistant 2.0'), subtitle: const Text('Career fit, CV tailoring and job application preparation'), onTap: () => _open(const CareerCoachPage())),
        ListTile(leading: const Icon(Icons.workspaces_outline), title: const Text('Professional Profiles & Freelancer Marketplace 2.0'), subtitle: const Text('Portfolios, proof of work and proposal preparation'), onTap: () => _open(const FreelancerMarketplacePage())),
        ListTile(leading: const Icon(Icons.groups_2_outlined), title: const Text('Professional Network 2.0'), subtitle: const Text('Networking, professional communities and opportunity discovery'), onTap: () => _open(const ProfessionalNetworkPage())),
        ListTile(leading: const Icon(Icons.handyman_outlined), title: const Text('Professional Services Marketplace 1.0'), subtitle: const Text('Hire verified professionals and offer services globally'), onTap: () => _open(const GlobalServicesMarketplacePage())),
        ListTile(leading: const Icon(Icons.event_available_outlined), title: const Text('Professional Booking & Contracts 2.0'), subtitle: const Text('Schedule services, request contracts and manage booking status'), onTap: () => _open(const ProfessionalBookingPage())),
        ListTile(leading: const Icon(Icons.payments_outlined), title: const Text('Professional Payments & Disputes 2.0'), subtitle: const Text('Escrow requests, payout release and dispute workflows'), onTap: () => _open(const ProfessionalPaymentsDisputesPage())),
        ListTile(leading: const Icon(Icons.public_outlined), title: const Text('Global Payments 3.0'), subtitle: const Text('Country, currency and payment-method preferences'), onTap: () => _open(const GlobalPaymentsPage())),
        ListTile(leading: const Icon(Icons.currency_exchange_outlined), title: const Text('International Commerce & FX 2.0'), subtitle: const Text('Multi-currency display, local pricing and FX quote requests'), onTap: () => _open(const FxCommercePage())),
        ListTile(leading: const Icon(Icons.local_shipping_outlined), title: const Text('Global Logistics & Delivery 2.0'), subtitle: const Text('Cross-border shipping, courier assignment and tracking'), onTap: () => _open(const GlobalLogisticsPage())),
        if (uid.isNotEmpty) ListTile(leading: const Icon(Icons.auto_awesome_outlined), title: const Text('Creator profile'), subtitle: const Text('Portfolio, audience and published content'), onTap: () => _open(CreatorProfilePage(creatorId: uid))),
        ListTile(leading: const Icon(Icons.verified_user_outlined), title: const Text('Global Identity Verification 2.0'), subtitle: const Text('Personal, professional and business identity trust workflow'), onTap: () => _open(const GlobalIdentityVerificationPage())),
        ListTile(leading: const Icon(Icons.gpp_good_outlined), title: const Text('Fraud Prevention & Security 2.0'), subtitle: const Text('Risk monitoring, transaction reports and account security review'), onTap: () => _open(const FraudRiskSecurityPage())),
        ListTile(leading: const Icon(Icons.phonelink_lock_outlined), title: const Text('Device Trust & Account Security 2.0'), subtitle: const Text('Trusted devices, session protection and recovery review'), onTap: () => _open(const DeviceTrustSecurityPage())),
        ListTile(leading: const Icon(Icons.fingerprint_outlined), title: const Text('Passkeys & MFA 2.0'), subtitle: const Text('High-security login and recovery protection'), onTap: () => _open(const MfaPasskeySecurityPage())),
        ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('Privacy Center 2.0'), subtitle: const Text('Data controls, export, deletion and transparency requests'), onTap: () => _open(const PrivacyCenterPage())),
        ListTile(leading: const Icon(Icons.policy_outlined), title: const Text('Data Governance & Consent 2.0'), subtitle: const Text('Regional consent, governance and compliance review'), onTap: () => _open(const DataGovernancePage())),
        ListTile(leading: const Icon(Icons.admin_panel_settings_outlined), title: const Text('Platform Governance & Safety 1.0'), subtitle: const Text('Global moderation, reports, appeals and enforcement workflows'), onTap: () => _open(const PlatformGovernancePage())),
        ListTile(leading: const Icon(Icons.auto_awesome_moderation_outlined), title: const Text('AI Safety & Abuse Prevention 2.0'), subtitle: const Text('Automated safety signals and review requests'), onTap: () => _open(const AdvancedModerationPage())),
        ListTile(leading: const Icon(Icons.family_restroom_outlined), title: const Text('Age & Family Safety 2.0'), subtitle: const Text('Age assurance, teen safety and family-protection controls'), onTap: () => _open(const AgeAssuranceFamilySafetyPage())),
        ListTile(leading: const Icon(Icons.health_and_safety_outlined), title: const Text('Teen Wellbeing & Safer Recommendations 2.0'), subtitle: const Text('Break reminders, quieter notifications and safer discovery controls'), onTap: () => _open(const TeenWellbeingPage())),
        ListTile(leading: const Icon(Icons.hub_outlined), title: const Text('Realtime Infrastructure 2.0'), subtitle: const Text('Presence, typing, heartbeat and global realtime architecture'), onTap: () => _open(const RealtimeInfrastructurePage())),
        ListTile(leading: const Icon(Icons.badge_outlined), title: const Text('Professional identity'), subtitle: const Text('Services, reputation and portfolio'), onTap: () { if (uid.isNotEmpty) _open(ProfessionalReputationPage(providerId: uid, providerName: displayName.text.isEmpty ? 'Professional' : displayName.text)); }),
        ListTile(leading: const Icon(Icons.auto_awesome_outlined), title: const Text('SwipeBuy AI 2.0'), subtitle: const Text('Text, voice and Vision AI command center'), onTap: () => _open(const AiCommandCenter2Page())),
        ListTile(leading: const Icon(Icons.schedule_send_outlined), title: const Text('AI Automation 2.0'), subtitle: const Text('Save recurring routines and smart tasks'), onTap: () => _open(const AiAutomationPage())),
        ListTile(leading: const Icon(Icons.smart_toy_outlined), title: const Text('AI Agents 2.0'), subtitle: const Text('Turn goals into safe multi-step task plans'), onTap: () => _open(const AiAgentsPage())),
        ListTile(leading: const Icon(Icons.apps_outlined), title: const Text('AI Agent Marketplace 2.0'), subtitle: const Text('Discover and install reusable AI task agents'), onTap: () => _open(const AiAgentMarketplacePage())),
        ListTile(leading: const Icon(Icons.verified_user_outlined), title: const Text('AI Agent Trust & Safety 2.0'), subtitle: const Text('Reviews, reports and personal trust signals'), onTap: () => _open(const AiAgentTrustPage())),
        ListTile(leading: const Icon(Icons.hub_outlined), title: const Text('Global AI Agent Platform 1.0'), subtitle: const Text('Unified agent workspace, marketplace, trust and creator economy'), onTap: () => _open(const AiAgentPlatformPage())),
        ListTile(leading: const Icon(Icons.psychology_outlined), title: const Text('AI Memory 2.0'), subtitle: const Text('Control preferences and context used for personalization'), onTap: () => _open(const AiMemoryPage())),
        ListTile(leading: const Icon(Icons.notifications_active_outlined), title: const Text('AI Proactive Assistant 3.0'), subtitle: const Text('Smart alerts for prices, jobs, property, deals and content'), onTap: () => _open(const AiProactiveAssistantPage())),
        ListTile(leading: const Icon(Icons.bolt_outlined), title: const Text('AI Real-World Actions 3.0'), subtitle: const Text('Prepare checkout, bookings, applications and safe handoffs'), onTap: () => _open(const AiRealWorldActionsPage())),
        ListTile(leading: const Icon(Icons.tune_outlined), title: const Text('Personalization'), subtitle: const Text('Interests, location and your For You feed'), onTap: () => _open(const PersonalizationPage())),
        ListTile(leading: const Icon(Icons.logout), title: const Text('Sign out'), onTap: AuthService.signOut),
      ]),
    ),
  );

  Future<void> _editProfile() async {
    final name = TextEditingController(text: displayName.text);
    final handle = TextEditingController(text: username.text);
    final about = TextEditingController(text: bio.text);
    final saved = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Edit profile'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Display name')),
        const SizedBox(height: 10),
        TextField(controller: handle, decoration: const InputDecoration(labelText: 'Username')),
        const SizedBox(height: 10),
        TextField(controller: about, maxLines: 4, decoration: const InputDecoration(labelText: 'Bio')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))],
    ));
    if (saved == true && mounted) {
      setState(() { displayName.text = name.text.trim(); username.text = handle.text.trim().replaceAll(' ', '').toLowerCase(); bio.text = about.text.trim(); });
      if (displayName.text.isNotEmpty) {
        try { await AuthService.updateDisplayName(displayName.text); } catch (_) {}
      }
    }
    name.dispose(); handle.dispose(); about.dispose();
  }
}
