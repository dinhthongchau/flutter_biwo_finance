import 'package:flutter/material.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:go_router/go_router.dart';

class ProfileSettingScreen extends StatelessWidget {
  static const String routeName = '/profile-setting-screen';
  const ProfileSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: Column(
        children: [
          // AppBar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 24,
                left: 8,
                right: 24,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/profile-screen'),
                  ),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.notifications_none,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          // Nội dung
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 80),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.honeydew,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    _buildSettingItem(
                      context,
                      icon: Icons.notifications,
                      label: 'Notification Settings',
                      onTap: () {
                        context.go('/profile-setting-notification');
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildSettingItem(
                      context,
                      icon: Icons.vpn_key,
                      label: 'Password Settings',
                      onTap: () {
                        context.go('/profile-setting-password');
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildSettingItem(
                      context,
                      icon: Icons.person,
                      label: 'Delete Account',
                      onTap: () {
                        context.go('/profile-setting-delete-account');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.caribbeanGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.blackHeader,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 26),
        ],
      ),
    );
  }
}
