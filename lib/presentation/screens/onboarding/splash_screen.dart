import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:finance_management/presentation/screens/authentication/login/login_screen.dart';
import 'package:finance_management/presentation/screens/authentication/sign_up/sign_up_screen.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash-screen';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  final List<Timer?> _timers = [null, null, null];

  // Add hover state
  bool _isNextHoveredA = false;
  bool _isNextHoveredB = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
    _startAutoNext(0, const Duration(seconds: 2));
  }

  void _startAutoNext(int page, Duration duration) {
    _timers[page]?.cancel();
    _timers[page] = Timer(duration, () {
      if (mounted && _currentPage == page) {
        _goToPage(page + 1);
      }
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(seconds: 2),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    for (var t in _timers) {
      t?.cancel();
    }
    super.dispose();
  }

  Widget _buildSplashA() {
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Center(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/FunctionalIcon/Logo-1.svg',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'FinWise',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOnboardingA() {
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 60),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Welcome To\nExpense Manager',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 2 / 3,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 192,
                              height: 192,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(
                                  alpha: (0.05 * 255).round().toDouble(),
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Image.asset(
                              'assets/FunctionalIcon/bankcard.png',
                              width: 160,
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        MouseRegion(
                          onEnter:
                              (_) => setState(() => _isNextHoveredA = true),
                          onExit:
                              (_) => setState(() => _isNextHoveredA = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color:
                                  _isNextHoveredA
                                      ? AppColors.caribbeanGreen.withValues(
                                        alpha: (0.15 * 255).round().toDouble(),
                                      )
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextButton(
                              onPressed: () => _goToPage(2),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text('Next'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [_buildDot(true), _buildDot(false)],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingB() {
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 60),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              '¿Are You Ready To\nTake Control Of Your Finaces?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 2 / 3,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 192,
                              height: 192,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(
                                  alpha: (0.05 * 255).round().toDouble(),
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Image.asset(
                              'assets/FunctionalIcon/ilustra.png',
                              width: 160,
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        MouseRegion(
                          onEnter:
                              (_) => setState(() => _isNextHoveredB = true),
                          onExit:
                              (_) => setState(() => _isNextHoveredB = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color:
                                  _isNextHoveredB
                                      ? AppColors.caribbeanGreen.withValues(
                                        alpha: (0.15 * 255).round().toDouble(),
                                      )
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextButton(
                              onPressed: () => _goToPage(3),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text('Next'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [_buildDot(false), _buildDot(true)],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplashB() {
    return Scaffold(
      backgroundColor: AppColors.honeydew,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/FunctionalIcon/Logo-2.svg',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 16),
              const Text(
                'FinWise',
                style: TextStyle(
                  color: AppColors.caribbeanGreen,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.blackHeader, fontSize: 14),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.caribbeanGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    minimumSize: const Size(0, 45),
                    elevation: 0,
                  ),
                  onPressed: () {
                    context.go(LoginScreen.routeName);
                  },
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    minimumSize: const Size(0, 45),
                    elevation: 0,
                  ),
                  onPressed: () {
                    context.go(SignUpScreen.routeName);
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
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.go('/forget-password-screen');
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.blackHeader,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color:
            active
                ? Colors.white
                : Colors.white.withValues(
                  alpha: (0.4 * 255).round().toDouble(),
                ),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
        if (index == 1) _startAutoNext(1, const Duration(seconds: 5));
        if (index == 2) _startAutoNext(2, const Duration(seconds: 5));
      },
      children: [
        _buildSplashA(),
        _buildOnboardingA(),
        _buildOnboardingB(),
        _buildSplashB(),
      ],
    );
  }
}
