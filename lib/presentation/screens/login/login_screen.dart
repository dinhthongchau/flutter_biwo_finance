import 'package:finance_management/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/login-screen";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isFacebookHovered = false;
  bool _isGoogleHovered = false;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await url_launcher.launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Builder(
        builder: (context) {
          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;
          return Column(
            children: [
              SizedBox(
                width: screenWidth,
                height: screenHeight * 1 / 5,
                child: Container(
                  color: AppColors.caribbeanGreen,
                  child: const Center(
                    child: Text(
                      'Welcome',
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
                        horizontal: 60,
                        vertical: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(height: 30),
                          const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'Username Or Email',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.blackHeader,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SvgPicture.asset(
                                  'assets/IconComponents/Icon Profile.svg',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              hintText: 'Example@example.com',
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
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'Password',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.blackHeader,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Icon(
                                  Icons.lock_outline,
                                  color: AppColors.lightBlue,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: SvgPicture.asset(
                                  _obscurePassword
                                      ? 'assets/FunctionalIcon/Vector-23.svg'
                                      : 'assets/FunctionalIcon/Vector-24.svg',
                                  width: 12,
                                  height: 12,
                                  colorFilter: const ColorFilter.mode(
                                    Color.fromARGB(255, 2, 2, 2),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              hintText: 'Password',
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

                          const SizedBox(height: 90),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 91,
                              right: 92,
                            ),
                            child: SizedBox(
                              width: double.infinity,
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
                                  context.go(HomeScreen.routeName);
                                },
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blackHeader,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                context.go('/forget-password-screen');
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.blackHeader,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 91,
                              right: 92,
                            ),
                            child: SizedBox(
                              width: double.infinity,
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
                          Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            margin: const EdgeInsets.only(
                              left: 45,
                              right: 40,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blackHeader,
                                    ),
                                    children: [
                                      TextSpan(text: 'Use '),
                                      TextSpan(
                                        text: 'Fingerprint',
                                        style: TextStyle(
                                          color: AppColors.vividBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: ' To Access'),
                                    ],
                                  ),
                                ),
                              ],
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      onEnter:
                                          (_) => setState(
                                            () => _isFacebookHovered = true,
                                          ),
                                      onExit:
                                          (_) => setState(
                                            () =>
                                                _isFacebookHovered = false,
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
                                                _isFacebookHovered
                                                    ? 1.2
                                                    : 1.0,
                                              ),
                                          child: SvgPicture.asset(
                                            'assets/IconComponents/Facebook.svg',
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
                                                _isGoogleHovered
                                                    ? 1.2
                                                    : 1.0,
                                              ),
                                          child: SvgPicture.asset(
                                            'assets/IconComponents/Google.svg',
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
                                  onTap: () {
                                    context.go('/signUp-screen');
                                  },
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
          );
        },
      ),
    );
  }
}
