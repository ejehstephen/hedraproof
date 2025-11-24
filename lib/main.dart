import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hedera_proof/models/receipt.dart';
import 'package:hedera_proof/models/user.dart';
import 'package:hedera_proof/providers/auth_provider.dart';
import 'package:hedera_proof/providers/navigation_provider.dart';
import 'package:hedera_proof/providers/receipt_provider.dart';
import 'package:hedera_proof/screens/auth_screen.dart';
import 'package:hedera_proof/screens/dashboard_screen.dart';
import 'package:hedera_proof/screens/history_screen.dart';
import 'package:hedera_proof/screens/landing_screen.dart';
import 'package:hedera_proof/screens/profile_screen.dart';
import 'package:hedera_proof/screens/verify_screen.dart';
import 'package:hedera_proof/theme/app_theme.dart';
import 'package:hedera_proof/widgets/sidebar_nav.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ReceiptAdapter());
  await Hive.openBox<Receipt>('receipts');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ReceiptProvider>(
          create: (context) => ReceiptProvider(
              Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => ReceiptProvider(auth),
        ),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      child: const HederaProofApp(),
    ),
  );
}

class HederaProofApp extends StatelessWidget {
  const HederaProofApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HederaProof',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) => FutureBuilder(
          future: auth.tryAutoLogin(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            if (auth.isAuthenticated) {
              return const MainLayout();
            }
            return const LandingScreen();
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A23),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E7FF)),
            ),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const VerifyScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    // This is a safeguard. If for any reason the user is null, log out.
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authProvider.logout();
      });
      return const SplashScreen(); // Show splash screen while logging out
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return isMobile
        ? _buildMobileLayout(context, user)
        : _buildDesktopLayout(context, user);
  }

  Widget _buildDesktopLayout(BuildContext context, User user) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: Row(
        children: [
          SidebarNav(
            selectedIndex: navigationProvider.currentIndex,
            onItemSelected: (index) => navigationProvider.updateIndex(index),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A0A23),
                    Color(0xFF0E0E2C),
                  ],
                ),
              ),
              child: _screens[navigationProvider.currentIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, User user) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HederaProof'),
        backgroundColor: const Color(0xFF0A0A23),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF0A0A23),
              ),
              child: const Text(
                'HederaProof',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: navigationProvider.currentIndex == 0,
              onTap: () {
                navigationProvider.updateIndex(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              selected: navigationProvider.currentIndex == 1,
              onTap: () {
                navigationProvider.updateIndex(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Verify Receipt'),
              selected: navigationProvider.currentIndex == 2,
              onTap: () {
                navigationProvider.updateIndex(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              selected: navigationProvider.currentIndex == 3,
              onTap: () {
                navigationProvider.updateIndex(3);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                authProvider.logout();
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A23),
              Color(0xFF0E0E2C),
            ],
          ),
        ),
        child: _screens[navigationProvider.currentIndex],
      ),
    );
  }
}
