import 'package:finance_management/presentation/screens/authentication/forget_password/new_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:finance_management/presentation/shared_data.dart' as shared;
import 'package:finance_management/gen/assets.gen.dart';

class SecurityPinScreen extends StatefulWidget {
  static const String routeName = '/security-pin-screen';

  const SecurityPinScreen({super.key});

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await url_launcher.launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildPinCircles() {
    String pin = _pinController.text;
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          bool filled = index < pin.length;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: shared.AppColors.caribbeanGreen,
                width: 3,
              ),
              shape: BoxShape.circle,
            ),
            child:
                filled
                    ? Text(
                      pin[index],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )
                    : const SizedBox.shrink(),
          );
        }),
      ),
    );
  }

  Widget _buildSocialIcon({
    required String asset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Center(
          child: SvgPicture.asset(
            asset,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shared.AppColors.caribbeanGreen,
      body: Stack(
        children: [
          const Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Security Pin',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: shared.AppColors.blackHeader,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.8,
              widthFactor: 1.0,
              child: Container(
                decoration: const BoxDecoration(
                  color: shared.AppColors.honeydew,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Enter Security Pin',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: shared.AppColors.blackHeader,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: 0.0,
                                  child: SizedBox(
                                    width: 0,
                                    height: 0,
                                    child: TextField(
                                      controller: _pinController,
                                      focusNode: _focusNode,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      onChanged: (_) => setState(() {}),
                                      autofocus: true,
                                    ),
                                  ),
                                ),
                                _buildPinCircles(),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      shared.AppColors.caribbeanGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  elevation: 0,
                                ),
                                onPressed:
                                    _pinController.text.length == 6
                                        ? () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return TweenAnimationBuilder(
                                                duration: const Duration(
                                                  milliseconds: 600,
                                                ),
                                                tween: Tween<double>(
                                                  begin: 0,
                                                  end: 1,
                                                ),
                                                builder: (
                                                  BuildContext context,
                                                  double value,
                                                  Widget? child,
                                                ) {
                                                  return Transform.scale(
                                                    scale: value,
                                                    child: AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              24,
                                                            ),
                                                      ),
                                                      backgroundColor:
                                                          shared
                                                              .AppColors
                                                              .honeydew,
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          TweenAnimationBuilder(
                                                            duration:
                                                                const Duration(
                                                                  milliseconds:
                                                                      800,
                                                                ),
                                                            tween:
                                                                Tween<double>(
                                                                  begin: 0,
                                                                  end: 1,
                                                                ),
                                                            builder: (
                                                              context,
                                                              double value,
                                                              child,
                                                            ) {
                                                              return Transform.scale(
                                                                scale: value,
                                                                child: Container(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        16,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: shared
                                                                        .AppColors
                                                                        .caribbeanGreen
                                                                        .withAlpha(
                                                                          (0.2 *
                                                                                  255)
                                                                              .round(),
                                                                        ),
                                                                    shape:
                                                                        BoxShape
                                                                            .circle,
                                                                  ),
                                                                  child: Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          16,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      color: shared
                                                                          .AppColors
                                                                          .caribbeanGreen
                                                                          .withAlpha(
                                                                            (0.3 *
                                                                                    255)
                                                                                .round(),
                                                                          ),
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
                                                                    ),
                                                                    child: const Icon(
                                                                      Icons
                                                                          .check_circle,
                                                                      color:
                                                                          shared
                                                                              .AppColors
                                                                              .caribbeanGreen,
                                                                      size: 64,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                            height: 24,
                                                          ),
                                                          TweenAnimationBuilder(
                                                            duration:
                                                                const Duration(
                                                                  milliseconds:
                                                                      800,
                                                                ),
                                                            tween:
                                                                Tween<double>(
                                                                  begin: 0,
                                                                  end: 1,
                                                                ),
                                                            builder: (
                                                              context,
                                                              double value,
                                                              child,
                                                            ) {
                                                              return Opacity(
                                                                opacity: value,
                                                                child: const Text(
                                                                  'Correct Pin!!!',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        shared
                                                                            .AppColors
                                                                            .blackHeader,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                            height: 24,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    shared
                                                                        .AppColors
                                                                        .caribbeanGreen,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        18,
                                                                      ),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      vertical:
                                                                          12,
                                                                    ),
                                                                elevation: 0,
                                                              ),
                                                              onPressed: () {
                                                                //context.pop();
                                                                context.go(
                                                                  NewPasswordScreen
                                                                      .routeName,
                                                                );
                                                              },
                                                              child: const Text(
                                                                'OK',
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      shared
                                                                          .AppColors
                                                                          .blackHeader,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        }
                                        : null,
                                child: const Text(
                                  'Accept',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: shared.AppColors.blackHeader,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: shared.AppColors.lightGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'Send Again',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: shared.AppColors.blackHeader,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'or sign up with',
                      style: TextStyle(fontSize: 13, color: Color(0xFFB0B0B0)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(
                          asset: Assets.iconComponents.facebook.path,
                          onTap: () => _launchURL('https://www.facebook.com'),
                        ),
                        const SizedBox(width: 24),
                        _buildSocialIcon(
                          asset: Assets.iconComponents.google.path,
                          onTap: () => _launchURL('https://www.google.com'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go('/signUp-screen');
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: shared.AppColors.lightBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
