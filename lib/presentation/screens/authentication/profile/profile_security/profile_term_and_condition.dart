import 'package:flutter/material.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_security/profile_security_screen.dart';

class ProfileTermAndConditionScreen extends StatefulWidget {
  static const String routeName = '/profile-term-and-condition';
  const ProfileTermAndConditionScreen({super.key});

  @override
  State<ProfileTermAndConditionScreen> createState() =>
      _ProfileTermAndConditionScreenState();
}

class _ProfileTermAndConditionScreenState
    extends State<ProfileTermAndConditionScreen> {
  bool _accepted = false;

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
                    onPressed: () => context.go('/profile-security-screen'),
                  ),
                  const Text(
                    'Terms And Conditions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Est Fugiat Assumenda Aut Reprehenderit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Lorem ipsum dolor sit amet. Et odio officia aut voluptate internos est omnis vitae ut architecto sunt non tenetur fuga ut provident vero. Quo aspernatur facere et consectetur ipsum et facere corrupti est asperiores facere. Est fugiat assumenda aut reprehenderit voluptatibus sed.',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    const Text('1. Ea voluptates omnis aut sequi sequi.'),
                    const Text(
                      '2. Est dolore quae in aliquid ducimus et autem repellendus.',
                    ),
                    const Text(
                      '3. Aut ipsum Quis qui porro quasi aut minus placeat!',
                    ),
                    const Text('4. Sit consequatur neque ab vitae facere.'),
                    const SizedBox(height: 12),
                    const Text(
                      'Aut quidem accusantium nam alias autem eum officiis placeat et omnis autem in officiis perspiciatis qui corrupti officia eum aliquam provident. Eum voluptatus error et optio dolorum cum molestiae nobis et odit molestiae quo magnam impedit sed fugiat nihil non nihil vitae.',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Aut fuga sequi eum voluptatibus provident.'),
                    const Text(
                      '• Eos consequuntur voluptas vel amet eaque aut dignissimos velit.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Vel exercitationem quam vel eligendi rerum At harum obcaecati et nostrum beatae? Ea accusantium dolores qui rerum aliquam est perferendis mollitia et ipsum ipsa qui enim autem At corporis sunt. Aut est quisquam est reprehenderit itaque aut accusantium dolor qui neque repellat.',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    const Text.rich(
                      TextSpan(
                        text:
                            'Read the terms and conditions in more detail at ',
                        style: TextStyle(fontSize: 15),
                        children: [
                          TextSpan(
                            text: 'www.finwiseapp.de',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Checkbox(
                          value: _accepted,
                          onChanged:
                              (v) => setState(() => _accepted = v ?? false),
                          activeColor: AppColors.caribbeanGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'I accept all the terms and conditions',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.caribbeanGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed:
                            _accepted
                                ? () =>
                                    context.go(ProfileSecurityScreen.routeName)
                                : null,
                        child: const Text(
                          'Accept',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
}
