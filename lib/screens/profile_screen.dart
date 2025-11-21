import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your account and view statistics',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFFA0A0B3),
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildStatsGrid(context),
            const SizedBox(height: 32),
            _buildBadgesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF7A5CFF).withOpacity(0.2),
            const Color(0xFF00E7FF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF7A5CFF).withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A5CFF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF7A5CFF), Color(0xFF00E7FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7A5CFF).withOpacity(0.5),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 40,
                color: Color(0xFFEAEAEA),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'User Account',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEAEAEA),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '0x92a0...A1F2',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF00E7FF),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00D77F).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00D77F).withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D77F),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Active',
                  style: TextStyle(
                    color: Color(0xFF00D77F),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GridView.count(
      crossAxisCount: isMobile ? 1 : 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          'Total Receipts',
          '12',
          Icons.receipt_long,
          const Color(0xFF00E7FF),
        ),
        _buildStatCard(
          'Verified',
          '10',
          Icons.verified_user_rounded,
          const Color(0xFF00D77F),
        ),
        _buildStatCard(
          'Pending',
          '2',
          Icons.schedule,
          const Color(0xFFFFA940),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0E0E2C).withOpacity(0.7),
            const Color(0xFF1A1A40).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFFA0A0B3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges & Achievements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFEAEAEA),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0E0E2C).withOpacity(0.7),
                const Color(0xFF1A1A40).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF7A5CFF).withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFA0A0B3),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Badges will be unlocked as you use HederaProof',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFFA0A0B3).withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
