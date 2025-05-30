import 'package:flutter/material.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_main/profile_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_security/profile_security_change_pin_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_security/profile_term_and_condition.dart';

class ProfileSecurityScreen extends StatelessWidget {
  static const String routeName = '/profile-security-screen';

  const ProfileSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: Column(
        children: [
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
                    onPressed: () => context.go(ProfileScreen.routeName),
                  ),
                  const Text(
                    'Security',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Security',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackHeader,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSecurityItem(
                      'Change Pin',
                      onTap: () {
                        GoRouter.of(
                          context,
                        ).push(ProfileSecurityChangePinScreen.routeName);
                      },
                    ),
                    _buildDivider(),
                    _buildSecurityItem('Fingerprint', onTap: () {}),
                    _buildDivider(),
                    _buildSecurityItem(
                      'Terms And Conditions',
                      onTap: () {
                        context.go(ProfileTermAndConditionScreen.routeName);
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

  Widget _buildSecurityItem(String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.blackHeader,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 26),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Color(0xFFE6E6E6), thickness: 1, height: 0);
  }
}
