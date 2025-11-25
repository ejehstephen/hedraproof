import 'package:flutter/material.dart';
import 'package:hedera_proof/screens/auth_screen.dart';
import 'package:hedera_proof/widgets/gradient_button.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToAuth() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A23),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A23),
              Color(0xFF0E0E2C),
              Color(0xFF1A1A40),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(isMobile),

            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20.0 : 60.0,
                    vertical: 40.0,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Hero Section
                          _buildHeroSection(isMobile),
                          const SizedBox(height: 80),

                          // Features Section
                          _buildFeaturesSection(isMobile),
                          const SizedBox(height: 80),

                          // Subscription Section
                          _buildSubscriptionSection(isMobile),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 20,
      ),
      color: const Color(0xFF0A0A23).withOpacity(0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/Screenshot 2025-11-25 104353.png', // Fixed path to plural 'assets'
                width: 63,
                height: 63, // Removed blue tint to show original logo
              ),
              const SizedBox(width: 12),
              Text(
                'HederaProof',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00E7FF),
                  shadows: [
                    BoxShadow(
                      color: const Color(0xFF00E7FF).withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isMobile)
            TextButton(
              onPressed: _navigateToAuth,
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Color(0xFFEAEAEA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    return Column(
      children: [
        Text(
          'The Future of\nDecentralized Receipts',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 36 : 56,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: const Color(0xFFEAEAEA),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Mint, Verify, and Track your NFT receipts securely on the Hedera network.\nSimple, transparent, and immutable proof of ownership.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 16 : 20,
            color: const Color(0xFFA0A0B3),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        GradientButton(
          label: 'Get Started',
          onPressed: _navigateToAuth,
          width: 200,
          icon: Icons.rocket_launch_outlined,
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(bool isMobile) {
    return Column(
      children: [
        const Text(
          'Why HederaProof?',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEAEAEA),
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 30,
          runSpacing: 30,
          alignment: WrapAlignment.center,
          children: [
            _buildFeatureCard(
              icon: Icons.token_outlined,
              title: 'Mint Receipts',
              description:
                  'Create immutable NFT receipts for any transaction instantly.',
              isMobile: isMobile,
            ),
            _buildFeatureCard(
              icon: Icons.verified_outlined,
              title: 'Verify Authenticity',
              description:
                  'Instantly verify the validity of any receipt on the network.',
              isMobile: isMobile,
            ),
            _buildFeatureCard(
              icon: Icons.history_edu_outlined,
              title: 'Track History',
              description:
                  'Keep a permanent record of all your minted and verified receipts.',
              isMobile: isMobile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isMobile,
  }) {
    return Container(
      width: isMobile ? double.infinity : 300,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A40).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF7A5CFF).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7A5CFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: const Color(0xFF7A5CFF),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEAEAEA),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFA0A0B3),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7A5CFF).withOpacity(0.1),
            const Color(0xFF00E7FF).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF00E7FF).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Pro Subscription',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEAEAEA),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Unlock advanced features and unlimited minting',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFA0A0B3),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildPricingFeature('Unlimited Receipt Minting'),
              _buildPricingFeature('Priority Verification'),
              _buildPricingFeature('Advanced Analytics'),
              _buildPricingFeature('API Access'),
            ],
          ),
          const SizedBox(height: 40),
          OutlinedButton(
            onPressed: _navigateToAuth,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF00E7FF)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View Plans',
              style: TextStyle(
                color: Color(0xFF00E7FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingFeature(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: Color(0xFF00E7FF),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFEAEAEA),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFF0A0A23),
      child: const Text(
        '© 2024 HederaProof. All rights reserved.',
        style: TextStyle(
          color: Color(0xFFA0A0B3),
          fontSize: 12,
        ),
      ),
    );
  }
}
