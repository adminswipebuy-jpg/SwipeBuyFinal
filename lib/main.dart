import 'services/personalization_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'jobs_page.dart';
import 'create_page.dart';
import 'listing_details.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'pages/notifications_page.dart';
import 'pages/smart_alerts_page.dart';
import 'pages/content_feed_page.dart';
import 'pages/stories_page.dart';
import 'pages/live_hub_page.dart';
import 'pages/communications_page.dart';
import 'pages/wallet_page.dart';
import 'pages/personalization_page.dart';
import 'pages/local_discovery_page.dart';
import 'pages/global_map_page.dart';
import 'pages/identity_profile_page.dart';
import 'pages/marketplace_v2_page.dart';
import 'pages/seller_commerce_pro_page.dart';
import 'pages/merchant_operations_page.dart';
import 'pages/global_search_intelligence_page.dart';
import 'pages/ai_assistant_workspace_page.dart';
import 'pages/marketing_growth_page.dart';
import 'pages/creator_brand_partnerships_page.dart';
import 'pages/professional_collaboration_page.dart';
import 'pages/v15_release_gate_page.dart';
import 'pages/integration_hub_page.dart';
import 'pages/core_flow_audit_page.dart';
import 'pages/final_integration_checklist_page.dart';
import 'pages/v15_release_candidate_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SwipeBuyApp());
}

class SwipeBuyApp extends StatelessWidget {
  const SwipeBuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwipeBuy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF07090D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.dark,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.hasData ? const MarketplaceShell() : const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;

  Future<void> login() async {
    setState(() { busy = true; error = null; });
    try {
      await AuthService.signIn(email.text.trim(), password.text);
    } catch (_) {
      if (mounted) setState(() => error = 'Sign-in failed. Check your email and password.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                const LogoHeader(),
                const SizedBox(height: 36),
                const Text('Welcome back', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('Buy. Book. Hire. Learn. Live Better.', style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 28),
                TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: field('Email', Icons.email_outlined)),
                const SizedBox(height: 12),
                TextField(controller: password, obscureText: true, decoration: field('Password', Icons.lock_outline)),
                if (error != null) Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: FilledButton(
                    onPressed: busy ? null : login,
                    child: busy ? const CircularProgressIndicator() : const Text('Sign in', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                TextButton(
                  onPressed: busy ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                  child: const Text('Create a SwipeBuy account'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

InputDecoration field(String label, IconData icon) => InputDecoration(
  labelText: label,
  prefixIcon: Icon(icon),
  filled: true,
  fillColor: const Color(0xFF121720),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  String type = 'customer';
  bool busy = false;
  String? error;

  Future<void> createAccount() async {
    if (name.text.trim().length < 2 || password.text.length < 6 || !email.text.contains('@')) {
      setState(() => error = 'Enter a valid name, email, and password of at least 6 characters.');
      return;
    }
    setState(() { busy = true; error = null; });
    try {
      await AuthService.createAccount(
  email: email.text.trim(),
  password: password.text,
  displayName: name.text.trim(),
  accountType: type,
);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => error = 'Could not create the account. Try again.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create account')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(controller: name, decoration: field('Full name', Icons.person_outline)),
        const SizedBox(height: 12),
        TextField(controller: email, decoration: field('Email', Icons.email_outlined)),
        const SizedBox(height: 12),
        TextField(controller: password, obscureText: true, decoration: field('Password', Icons.lock_outline)),
        const SizedBox(height: 18),
        const Text('Account type', style: TextStyle(fontWeight: FontWeight.bold)),
        for (final item in const [
          ('Customer', 'customer'),
          ('Business / Seller', 'business'),
          ('Freelancer / Professional', 'freelancer')
        ])
          RadioListTile<String>(
            title: Text(item.$1),
            value: item.$2,
            groupValue: type,
            onChanged: (v) => setState(() => type = v!),
          ),
        if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 12),
        SizedBox(height: 52, child: FilledButton(onPressed: busy ? null : createAccount, child: busy ? const CircularProgressIndicator() : const Text('Create account'))),
      ],
    ),
  );
}

class MarketplaceShell extends StatefulWidget {
  const MarketplaceShell({super.key});
  @override
  State<MarketplaceShell> createState() => _MarketplaceShellState();
}

class _MarketplaceShellState extends State<MarketplaceShell> {
  int index = 0;
  final pages = [HomePage(), JobsPage(), CreatePage(), CommunicationsPage(), IdentityProfilePage()];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: index, children: pages),
    bottomNavigationBar: NavigationBar(
      backgroundColor: const Color(0xFF0B1017),
      selectedIndex: index,
      onDestinationSelected: (v) => setState(() => index = v),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
        NavigationDestination(icon: Icon(Icons.add_circle_outline, size: 30), selectedIcon: Icon(Icons.add_circle, size: 30), label: 'Create'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chats'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  );
}

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: const LinearGradient(colors: [Color(0xFFFF7A18), Color(0xFF10B981)]),
        ),
        child: const Center(child: Text('S', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900))),
      ),
      const SizedBox(width: 10),
      const Text('SwipeBuy', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -1)),
    ],
  );
}

const categories = [
  ('For You', Icons.auto_awesome),
  ('Jobs', Icons.work),
  ('Food', Icons.restaurant),
  ('Hotels', Icons.hotel),
  ('Beauty', Icons.spa),
  ('Lifestyle', Icons.weekend),
  ('Entertainment', Icons.music_note),
  ('Education', Icons.school),
  ('Property', Icons.apartment),
  ('Sports', Icons.sports_soccer),
  ('News', Icons.newspaper),
  ('Forex', Icons.currency_exchange),
  ('Crypto', Icons.currency_bitcoin),
  ('Investment', Icons.trending_up),
  ('Real Estate', Icons.home_work),
  ('Fitness', Icons.fitness_center),
  ('Travel', Icons.flight_takeoff),
  ('Services', Icons.build),
];

final listings = <Listing>[
  Listing('Black Stars Match Highlights', 'Joy Sports', 'Sports', 'Ghana', 'Watch Now', 'Football • Live highlights', Icons.sports_soccer, Colors.deepPurple, '24.5K', '1.2K'),
  Listing('Mama Abena Chop Bar', 'Verified Business', 'Food', 'Wa, Ghana', 'Order Now • Pay with MoMo', 'Jollof & grilled chicken • GHS 45', Icons.restaurant, Colors.orange, '8.2K', '342'),
  Listing('Grand Hotel Paris', 'Verified Hotel', 'Hotels', 'Paris, France', 'Book Now', r'$89/night • 4.8★', Icons.hotel, Colors.green, '12.4K', '342'),
  Listing('Glow Skincare Studio', 'Verified Beauty Pro', 'Beauty', 'Wa, Ghana', 'Book Appointment', 'Facial & skincare • GHS 150', Icons.spa, Colors.pink, '6.4K', '188'),
  Listing('Modern Living Room Set', 'HomeStyle', 'Lifestyle', 'Accra, Ghana', 'Buy Now', 'Furniture set • GHS 2,450', Icons.weekend, Colors.amber, '4.1K', '92'),
  Listing('The Weekend Concert', 'Event Partner', 'Entertainment', 'Accra, Ghana', 'Get Ticket', 'Live event • GHS 120', Icons.music_note, Colors.purple, '18.2K', '710'),
  Listing('Digital Marketing Course', 'Verified Academy', 'Education', 'Online', 'Enroll Now', 'Beginner course • GHS 200', Icons.school, Colors.blue, '5.7K', '205'),
  Listing('City Apartment', 'Verified Property', 'Property', 'Accra, Ghana', 'View Property', '2-bedroom • GHS 4,500/month', Icons.apartment, Colors.teal, '3.2K', '64'),
  Listing('USD/GHS Market Watch', 'SwipeBuy Finance', 'Forex', 'Global', 'Open Market', 'Live currency information • Educational content', Icons.currency_exchange, Colors.green, '14.2K', '386'),
  Listing('Bitcoin Market Update', 'SwipeBuy Crypto', 'Crypto', 'Global', 'View Market', 'Price, trends & educational analysis', Icons.currency_bitcoin, Colors.orange, '18.7K', '921'),
  Listing('Beginner Investing Guide', 'SwipeBuy Invest', 'Investment', 'Global', 'Start Learning', 'Stocks, diversification & risk basics', Icons.trending_up, Colors.blue, '9.4K', '512'),
  Listing('Real Estate Opportunities', 'SwipeBuy Property', 'Real Estate', 'Ghana', 'Explore Property', 'Homes, land & rentals', Icons.home_work, Colors.teal, '6.8K', '244'),
  Listing('30-Day Fitness Challenge', 'SwipeBuy Fitness', 'Fitness', 'Online', 'Start Workout', 'Beginner-friendly workouts & routines', Icons.fitness_center, Colors.pink, '11.3K', '607'),
  Listing('Ghana Today', 'SwipeBuy News', 'News', 'Ghana', 'Read Full Story', 'Breaking stories, business & technology', Icons.newspaper, Colors.deepPurple, '21.6K', '1.4K'),
  Listing('Explore Ghana', 'SwipeBuy Travel', 'Travel', 'Ghana', 'Explore Places', 'Hotels, tours, attractions & experiences', Icons.flight_takeoff, Colors.cyan, '8.5K', '318'),
  Listing('Professional Web Developer', 'Verified Pro', 'Services', 'Remote', 'Hire Now', 'Web development • From GHS 400', Icons.code, Colors.cyan, '7.1K', '231'),
  Listing('Driver Needed in Wa', 'Alhaji Transport', 'Jobs', 'Wa, Ghana', 'Apply Now • 1 Click', 'GHS 1,500/month • Full-time', Icons.directions_car, Colors.indigo, '2.1K', '32'),
];

final professionals = [
  Professional('Ama Mensah', 'UI/UX Designer', 'Design & Creative', '4.9', 'GHS 300', Icons.design_services),
  Professional('Kwame Boateng', 'Web Developer', 'Tech & Development', '4.9', 'GHS 400', Icons.code),
  Professional('Esi Owusu', 'Digital Marketer', 'Marketing & Growth', '4.8', 'GHS 250', Icons.campaign),
  Professional('Kojo Addo', 'Photographer', 'Photo & Video', '4.8', 'GHS 350', Icons.camera_alt),
  Professional('Mariam Ali', 'Accountant', 'Finance & Tax', '4.8', 'GHS 300', Icons.calculate),
  Professional('Nana Yaa', 'Content Writer', 'Writing & Translation', '4.7', 'GHS 200', Icons.edit_note),
];

class Listing {
  final String id, ownerId, title, seller, category, location, action, subtitle, stat1, stat2;
  final IconData icon;
  final Color accent;
  Listing(this.title, this.seller, this.category, this.location, this.action, this.subtitle, this.icon, this.accent, this.stat1, this.stat2, {this.id = '', this.ownerId = ''});
}

class Professional {
  final String name, role, category, rating, price;
  final IconData icon;
  Professional(this.name, this.role, this.category, this.rating, this.price, this.icon);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selected = 0;
  List<(String, IconData)> orderedCategories = categories;
  bool loadingOrder = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryOrder();
  }

  Future<void> _loadCategoryOrder() async {
    try {
      final names = categories.map((c) => c.$1).toList();
      final orderedNames = await PersonalizationService().categoryOrder(names);
      final byName = {for (final c in categories) c.$1: c};
      final reordered = orderedNames
          .map((name) => byName[name])
          .whereType<(String, IconData)>()
          .toList();
      if (mounted) {
        setState(() {
          orderedCategories = reordered;
          loadingOrder = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loadingOrder = false);
    }
  }

  void _open(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Widget _quickAction(String label, IconData icon, Color accent, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFF111822),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: .14),
              ),
              child: Icon(icon, color: accent, size: 21),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStrip(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF14231F), Color(0xFF0F1620)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF38D9A9).withValues(alpha: .14)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Everything you need, one swipe away', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, height: 1.05)),
                SizedBox(height: 6),
                Text('Discover content, products, jobs, places and opportunities made for you.', style: TextStyle(color: Colors.white70, height: 1.25)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFFF7A18), Color(0xFF10B981)]),
            ),
            child: const Icon(Icons.swipe_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = selected.clamp(0, orderedCategories.length - 1);
    final category = orderedCategories[safeIndex].$1;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 6),
            child: Row(
              children: [
                const LogoHeader(),
                const Spacer(),
                IconButton(onPressed: () => _open(const UniversalSearchPage()), icon: const Icon(Icons.search_rounded, size: 25)),
                IconButton(onPressed: () => _open(NotificationsPage()), icon: const Icon(Icons.notifications_none_rounded, size: 25)),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded, size: 25),
                  onSelected: (value) {
                    switch (value) {
                      case 'ai': _open(AiAssistantWorkspacePage()); break;
case 'nearby': _open(LocalDiscoveryPage()); break;
case 'map': _open(GlobalMapPage()); break;
case 'alerts': _open(SmartAlertsPage()); break;
case 'settings': _open(PersonalizationPage()); break;
case 'marketplace': _open(MarketplaceV2Page()); break;
case 'seller': _open(SellerCommerceProPage()); break;
case 'merchant_ops': _open(MerchantOperationsPage()); break;
case 'marketing': _open(MarketingGrowthPage()); break;
case 'partnerships': _open(CreatorBrandPartnershipsPage()); break;
case 'collaboration': _open(ProfessionalCollaborationPage()); break;
case 'integration': _open(IntegrationHubPage()); break;
case 'audit': _open(CoreFlowAuditPage()); break;
case 'finalcheck': _open(FinalIntegrationChecklistPage()); break;
case 'v15candidate': _open(V15ReleaseCandidatePage()); break;
case 'v15gate': _open(V15ReleaseGatePage()); break;
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'ai', child: Text('Ask SwipeBuy')),
                    PopupMenuItem(value: 'nearby', child: Text('Nearby')),
                    PopupMenuItem(value: 'map', child: Text('Global Map')),
                    PopupMenuItem(value: 'alerts', child: Text('Smart Alerts')),
                    PopupMenuItem(value: 'settings', child: Text('Personalize')),
                    PopupMenuItem(value: 'marketplace', child: Text('Marketplace 2.0')),
                    PopupMenuItem(value: 'seller', child: Text('Seller Commerce Pro')),
                    PopupMenuItem(value: 'merchant_ops', child: Text('Merchant Operations')),
                    PopupMenuItem(value: 'marketing', child: Text('Marketing & Growth')),
                    PopupMenuItem(value: 'partnerships', child: Text('Creator Partnerships')),
                    PopupMenuItem(value: 'collaboration', child: Text('Professional Collaboration')),
                    PopupMenuItem(value: 'integration', child: Text('Integration Hub')),
                    PopupMenuItem(value: 'v15gate', child: Text('V15 Release Gate')),
                    PopupMenuItem(value: 'audit', child: Text('Core Flow Audit')),
                    PopupMenuItem(value: 'finalcheck', child: Text('Final Integration Checklist')),
                    PopupMenuItem(value: 'v15candidate', child: Text('V15 Release Candidate')),
                  ],
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                _quickAction('AI', Icons.auto_awesome, const Color(0xFFFFB020), () => _open(const AiAssistantWorkspacePage())),
                const SizedBox(width: 8),
                _quickAction('Nearby', Icons.near_me_rounded, const Color(0xFF10B981), () => _open(const LocalDiscoveryPage())),
                const SizedBox(width: 8),
                _quickAction('Map', Icons.map_rounded, const Color(0xFF4F9BFF), () => _open(const GlobalMapPage())),
                const SizedBox(width: 8),
                _quickAction('Stories', Icons.auto_stories_rounded, const Color(0xFFFF4D6D), () => _open(const StoriesPage())),
                const SizedBox(width: 8),
                _quickAction('LIVE', Icons.live_tv_rounded, const Color(0xFFFF4D4D), () => _open(const LiveHubPage())),
                const SizedBox(width: 8),
                _quickAction('Wallet', Icons.account_balance_wallet_rounded, const Color(0xFF9B7BFF), () => _open(const WalletPage())),
                const SizedBox(width: 8),
                _quickAction('Shop', Icons.shopping_bag_rounded, const Color(0xFFFF7A18), () => _open(const MarketplaceV2Page())),
              ],
            ),
          ),
          _heroStrip(context),
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: orderedCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (_, i) => ChoiceChip(
                avatar: Icon(orderedCategories[i].$2, size: 16),
                label: Text(orderedCategories[i].$1),
                selected: selected == i,
                onSelected: (_) => setState(() => selected = i),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(child: ContentFeedView(category: category)),
        ],
      ),
    );
  }
}

String _actionFor(String category) {
  switch (category) {
    case 'Jobs': return 'Apply Now';
    case 'Food': return 'Order Now';
    case 'Hotels': return 'Book Now';
    case 'Beauty': return 'Book Appointment';
    case 'Education': return 'Enroll Now';
    case 'Entertainment': return 'Get Ticket';
    case 'Services': return 'Hire Now';
    case 'News': return 'Read Full Story';
    case 'Forex': return 'Open Market';
    case 'Crypto': return 'View Market';
    case 'Investment': return 'Start Learning';
    case 'Real Estate': return 'Explore Property';
    case 'Fitness': return 'Start Workout';
    case 'Travel': return 'Explore Places';
    default: return 'View Details';
  }
}

IconData _iconFor(String category) {
  switch (category) {
    case 'Jobs': return Icons.work;
    case 'Food': return Icons.restaurant;
    case 'Hotels': return Icons.hotel;
    case 'Beauty': return Icons.spa;
    case 'Lifestyle': return Icons.weekend;
    case 'Entertainment': return Icons.music_note;
    case 'Education': return Icons.school;
    case 'Property': return Icons.apartment;
    case 'Sports': return Icons.sports_soccer;
    case 'News': return Icons.newspaper;
    case 'Forex': return Icons.currency_exchange;
    case 'Crypto': return Icons.currency_bitcoin;
    case 'Investment': return Icons.trending_up;
    case 'Real Estate': return Icons.home_work;
    case 'Fitness': return Icons.fitness_center;
    case 'Travel': return Icons.flight_takeoff;
    default: return Icons.build;
  }
}

Color _accentFor(String category) {
  switch (category) {
    case 'Food': return Colors.orange;
    case 'Hotels': return Colors.green;
    case 'Beauty': return Colors.pink;
    case 'Education': return Colors.blue;
    case 'Entertainment': return Colors.purple;
    case 'Property': return Colors.teal;
    case 'Jobs': return Colors.indigo;
    case 'News': return Colors.deepPurple;
    case 'Forex': return Colors.green;
    case 'Crypto': return Colors.orange;
    case 'Investment': return Colors.blue;
    case 'Real Estate': return Colors.teal;
    case 'Fitness': return Colors.pink;
    case 'Travel': return Colors.cyan;
    default: return const Color(0xFF38D9A9);
  }
}

class SwipeListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onOpen;
  const SwipeListingCard({super.key, required this.listing, required this.onOpen});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(26),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF101722),
            listing.accent.withValues(alpha: .25),
            const Color(0xFF080B10),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: MarketplaceArtPainter(icon: listing.icon, accent: listing.accent))),
          Positioned(top: 16, left: 16, child: Pill(text: listing.category)),
          Positioned(
            right: 12, top: 78,
            child: Column(children: [
              FeedStat(icon: Icons.favorite, text: listing.stat1),
              const SizedBox(height: 18),
              FeedStat(icon: Icons.chat_bubble_outline, text: listing.stat2),
              const SizedBox(height: 18),
              const FeedStat(icon: Icons.share_outlined, text: '892'),
              const SizedBox(height: 18),
              const FeedStat(icon: Icons.bookmark_border, text: '203'),
            ]),
          ),
          Positioned(
            left: 18, right: 64, bottom: 18,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(radius: 18, backgroundColor: listing.accent.withValues(alpha: .25), child: Icon(listing.icon, color: listing.accent)),
                const SizedBox(width: 9),
                Expanded(child: Text(listing.seller, style: const TextStyle(fontWeight: FontWeight.w800))),
                const Icon(Icons.verified, size: 18, color: Color(0xFF38D9A9)),
              ]),
              const SizedBox(height: 10),
              Text(listing.title, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, height: 1.05)),
              const SizedBox(height: 6),
              Text('• ${listing.location}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(listing.subtitle, style: const TextStyle(color: Colors.white60)),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity, height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: listing.accent),
                  onPressed: onOpen,
                  child: Text(listing.action, style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ]),
          ),
        ],
      ),
    ),
  );
}

class MarketplaceArtPainter extends CustomPainter {
  final IconData icon;
  final Color accent;
  MarketplaceArtPainter({required this.icon, required this.accent});

  @override
  void paint(Canvas c, Size s) {
    final glow = Paint()..color = accent.withValues(alpha: .10);
    c.drawCircle(Offset(s.width * .55, s.height * .34), s.width * .36, glow);
    final grid = Paint()..color = Colors.white.withValues(alpha: .035)..strokeWidth = 1;
    for (double x = 0; x < s.width; x += 44) {
      c.drawLine(Offset(x, 0), Offset(x, s.height), grid);
    }
    for (double y = 0; y < s.height; y += 44) {
      c.drawLine(Offset(0, y), Offset(s.width, y), grid);
    }
    final tp = TextPainter(
      text: TextSpan(text: String.fromCharCode(icon.codePoint), style: TextStyle(fontSize: 190, fontFamily: icon.fontFamily, package: icon.fontPackage, color: accent.withValues(alpha: .20))),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset((s.width - tp.width) / 2, s.height * .20));
  }

  @override
  bool shouldRepaint(covariant MarketplaceArtPainter oldDelegate) => oldDelegate.icon != icon || oldDelegate.accent != accent;
}

class Pill extends StatelessWidget {
  final String text;
  const Pill({super.key, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white12)),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

class FeedStat extends StatelessWidget {
  final IconData icon;
  final String text;
  const FeedStat({super.key, required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Column(children: [Icon(icon, size: 29), const SizedBox(height: 3), Text(text, style: const TextStyle(fontWeight: FontWeight.bold))]);
}



class UniversalSearchPage extends StatefulWidget {
  const UniversalSearchPage({super.key});
  @override
  State<UniversalSearchPage> createState() => _UniversalSearchPageState();
}

class _UniversalSearchPageState extends State<UniversalSearchPage> {
  final controller = TextEditingController();
  String query = '';
  String filter = 'All';
  String sort = 'Relevance';
  final List<String> recentSearches = [];

  final filters = const ['All', 'People', 'Businesses', 'Products', 'Jobs', 'News', 'Sports', 'Finance', 'Property'];

  List<Map<String, dynamic>> get results {
    final q = query.trim().toLowerCase();
    final base = <Map<String, dynamic>>[
      ...listings.map((x) => {'type': _typeForSearch(x.category), 'title': x.title, 'subtitle': '${x.seller} • ${x.location}', 'category': x.category, 'icon': x.icon}),
      ...professionals.map((p) => {'type': 'People', 'title': p.name, 'subtitle': '${p.role} • ${p.category}', 'category': 'Services', 'icon': p.icon}),
      ...categories.skip(1).map((c) => {'type': 'Category', 'title': c.$1, 'subtitle': 'Explore ${c.$1} on SwipeBuy', 'category': c.$1, 'icon': c.$2}),
    ];
    final matched = base.where((x) {
      final hay = '${x['title']} ${x['subtitle']} ${x['category']}'.toLowerCase();
      final matchesQuery = q.isEmpty || hay.contains(q);
      final matchesFilter = filter == 'All' || x['type'] == filter || (filter == 'People' && x['type'] == 'People');
      return matchesQuery && matchesFilter;
    }).toList();
    if (sort == 'A–Z') {
      matched.sort((a, b) => (a['title'] as String).toLowerCase().compareTo((b['title'] as String).toLowerCase()));
    } else if (sort == 'Category') {
      matched.sort((a, b) => (a['category'] as String).compareTo((b['category'] as String)));
    }
    return matched.take(60).toList();
  }

  String _typeForSearch(String category) {
    if (category == 'Jobs') return 'Jobs';
    if (category == 'News') return 'News';
    if (category == 'Sports') return 'Sports';
    if ({'Forex','Crypto','Investment'}.contains(category)) return 'Finance';
    if ({'Property','Real Estate'}.contains(category)) return 'Property';
    if (category == 'Services') return 'People';
    if ({'Food','Hotels','Beauty','Lifestyle','Entertainment','Education','Fitness','Travel'}.contains(category)) return 'Products';
    return 'Businesses';
  }

  @override
  Widget build(BuildContext context) {
    final trending = const ['Football today', 'iPhone', 'Jobs in Ghana', 'Forex', 'Apartments in Accra'];
    final suggestions = query.trim().isEmpty ? trending : [
      '$query near me',
      'best $query',
      '$query jobs',
      '$query deals',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Search SwipeBuy'), actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalSearchIntelligencePage())), icon: const Icon(Icons.open_in_new))]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: TextField(
            controller: controller,
            autofocus: true,
            onChanged: (v) => setState(() => query = v),
            onSubmitted: (v) => setState(() { query = v; if (v.trim().isNotEmpty) { recentSearches.remove(v.trim()); recentSearches.insert(0, v.trim()); } }),
            decoration: InputDecoration(
              hintText: 'Search anything on SwipeBuy…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty ? null : IconButton(onPressed: () { controller.clear(); setState(() => query = ''); }, icon: const Icon(Icons.close)),
              filled: true,
              fillColor: const Color(0xFF121720),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 7),
            itemBuilder: (_, i) => ChoiceChip(label: Text(filters[i]), selected: filter == filters[i], onSelected: (_) => setState(() => filter = filters[i])),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
          child: Row(children: [
            const Text('Sort', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Expanded(child: DropdownButtonFormField<String>(
              initialValue: sort,
              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Relevance', child: Text('Relevance')),
                DropdownMenuItem(value: 'A–Z', child: Text('A–Z')),
                DropdownMenuItem(value: 'Category', child: Text('Category')),
              ],
              onChanged: (v) => setState(() => sort = v ?? 'Relevance'),
            )),
          ]),
        ),
        if (query.isEmpty) ...[
          const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.fromLTRB(18, 16, 18, 10), child: Text('Trending searches', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(spacing: 8, runSpacing: 8, children: trending.map((t) => ActionChip(label: Text(t), onPressed: () { controller.text = t; setState(() { query = t; recentSearches.remove(t); recentSearches.insert(0, t); }); })).toList()),
          ),
          if (recentSearches.isNotEmpty) ...[
            const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.fromLTRB(18, 20, 18, 8), child: Text('Recent searches', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Wrap(spacing: 8, runSpacing: 8, children: recentSearches.take(6).map((t) => InputChip(label: Text(t), onPressed: () { controller.text = t; setState(() => query = t); }, onDeleted: () => setState(() => recentSearches.remove(t)))).toList())),
          ],
          const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.fromLTRB(18, 20, 18, 8), child: Text('Explore', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)))),
        ] else ...[
          const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.fromLTRB(18, 12, 18, 8), child: Text('Smart suggestions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Wrap(spacing: 8, runSpacing: 8, children: suggestions.map((t) => ActionChip(label: Text(t), onPressed: () { controller.text = t; setState(() { query = t; recentSearches.remove(t); recentSearches.insert(0, t); }); })).toList())),
        ],
        Expanded(
          child: results.isEmpty
            ? const Center(child: Text('No results found. Try another search.'))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final r = results[i];
                  return Card(
                    color: const Color(0xFF111720),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: const Color(0xFF173A31), child: Icon(r['icon'] as IconData, color: const Color(0xFF38D9A9))),
                      title: Text(r['title'] as String, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${r['type']} • ${r['subtitle']}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        final title = r['title'] as String;
                        final listing = listings.where((x) => x.title == title).cast<Listing?>().firstWhere((x) => x != null, orElse: () => null);
                        if (listing != null) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetails(listing: listing)));
                        } else if (r['type'] == 'People') {
                          final person = professionals.firstWhere((p) => p.name == title, orElse: () => professionals.first);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProfessionalProfile(person: person)));
                        } else if (categories.any((c) => c.$1 == title)) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryHubPage(category: title)));
                        }
                      },
                    ),
                  );
                },
              ),
        ),
      ]),
    );
  }
}

class ExploreCategoriesPage extends StatelessWidget {
  const ExploreCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Explore SwipeBuy')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('One app. Endless opportunities.', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
        const SizedBox(height: 7),
        const Text('Discover content, products, people and opportunities in one personalized experience.', style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalDiscoveryPage())), icon: const Icon(Icons.near_me_outlined), label: const Text('Nearby'))),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalMapPage())), icon: const Icon(Icons.map_outlined), label: const Text('Map'))),
        ]),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.35,
          children: categories.skip(1).map((c) => InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryHubPage(category: c.$1))),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111720),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Icon(c.$2, size: 30, color: const Color(0xFF38D9A9)),
                Text(c.$1, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              ]),
            ),
          )).toList(),
        ),
        const SizedBox(height: 18),
        Card(
          color: const Color(0xFF12382E),
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Row(children: [
              Icon(Icons.public, size: 34, color: Color(0xFF38D9A9)),
              SizedBox(width: 14),
              Expanded(child: Text('Go global with SwipeBuy. Discover local opportunities today and connect with the world tomorrow.', style: TextStyle(fontWeight: FontWeight.w700))),
            ]),
          ),
        ),
      ],
    ),
  );
}

class CategoryHubPage extends StatelessWidget {
  final String category;
  const CategoryHubPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final items = category == 'For You' ? listings : listings.where((x) => x.category == category).toList();
    final shown = items.isEmpty ? listings.take(3).toList() : items;
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: shown.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          child: SwipeListingCard(
            listing: shown[i],
            onOpen: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetails(listing: shown[i]))),
          ),
        ),
      ),
    );
  }
}
