import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management/presentation/shared_data.dart';

class ForgetPasswordScreen extends StatefulWidget {
  static const String routeName = "/forget-password-screen";

  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  bool _isFacebookHovered = false;
  bool _isGoogleHovered = false;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: screenWidth,
                height: screenHeight * 1 / 5,
                child: Container(
                  color: AppColors.caribbeanGreen,
                  child: const Center(
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackHeader,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth,
                height: screenHeight * 4 / 5,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.honeydew,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(48),
                      topRight: Radius.circular(48),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'Reset Password?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppColors.blackHeader,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.blackHeader,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Enter Email Address',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.blackHeader,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'example@example.com',
                              filled: true,
                              fillColor: AppColors.lightGreen,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: SizedBox(
                              width: 220,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.caribbeanGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  minimumSize: const Size(0, 45),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  context.go('/security-pin-screen');
                                },
                                child: const Text(
                                  'Next Step',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blackHeader,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: SizedBox(
                              width: 220,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  minimumSize: const Size(0, 45),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  context.go('/signUp-screen');
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blackHeader,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  'or sign up with',
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      onEnter:
                                          (_) => setState(
                                            () => _isFacebookHovered = true,
                                          ),
                                      onExit:
                                          (_) => setState(
                                            () => _isFacebookHovered = false,
                                          ),
                                      child: GestureDetector(
                                        onTap:
                                            () => _launchURL(
                                              'https://www.facebook.com',
                                            ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          transform:
                                              Matrix4.identity()..scale(
                                                _isFacebookHovered ? 1.2 : 1.0,
                                              ),
                                          child: SvgPicture.asset(
                                            Assets.iconComponents.facebook.path,
                                            width: 32,
                                            height: 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      onEnter:
                                          (_) => setState(
                                            () => _isGoogleHovered = true,
                                          ),
                                      onExit:
                                          (_) => setState(
                                            () => _isGoogleHovered = false,
                                          ),
                                      child: GestureDetector(
                                        onTap:
                                            () => _launchURL(
                                              'https://www.google.com',
                                            ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          transform:
                                              Matrix4.identity()..scale(
                                                _isGoogleHovered ? 1.2 : 1.0,
                                              ),
                                          child: SvgPicture.asset(
                                            Assets.iconComponents.google.path,
                                            width: 32,
                                            height: 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(fontSize: 12),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: AppColors.vividBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
