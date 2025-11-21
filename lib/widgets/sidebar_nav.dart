import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class SidebarNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SidebarNav({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkGradientStart,
            AppColors.deepNavyBg,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          right: BorderSide(
            color: AppColors.primaryPurple.withAlpha((255 * 0.3).round()),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryPurple,
                        AppColors.cygnGlow,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withAlpha((255 * 0.5).round()),
                        blurRadius: 15,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.cygnGlow],
                  ).createShader(bounds),
                  child: Text(
                    'HederaProof',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderGray),
          // Navigation Items
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                _NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isSelected: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                ),
                _NavItem(
                  icon: Icons.history,
                  label: 'History',
                  isSelected: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                ),
                _NavItem(
                  icon: Icons.verified_user,
                  label: 'Verify Receipt',
                  isSelected: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                ),
                _NavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isSelected: selectedIndex == 3,
                  onTap: () => onItemSelected(3),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Wallet Status
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPurple.withAlpha((255 * 0.2).round()),
                    AppColors.cygnGlow.withAlpha((255 * 0.1).round()),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryPurple.withAlpha((255 * 0.4).round()),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected Wallet',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.successGreen.withAlpha((255 * 0.5).round()),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '0x92...A1F2',
                          style: AppTextStyles.body2.copyWith(
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        colors: [
                          AppColors.primaryPurple.withAlpha((255 * 0.3).round()),
                          AppColors.cygnGlow.withAlpha((255 * 0.1).round()),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : _isHovered
                        ? LinearGradient(
                            colors: [
                              AppColors.primaryPurple.withAlpha((255 * 0.1).round()),
                              Colors.transparent,
                            ],
                          )
                        : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isSelected
                      ? AppColors.primaryPurple.withAlpha((255 * 0.5).round())
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    color: widget.isSelected
                        ? AppColors.cygnGlow
                        : AppColors.mutedGrayText,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: AppTextStyles.body1.copyWith(
                        color: widget.isSelected
                            ? AppColors.softWhiteText
                            : AppColors.mutedGrayText,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
