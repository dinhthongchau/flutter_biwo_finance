import 'package:finance_management/presentation/screens/analysis/analysis_screen.dart';
import 'package:finance_management/presentation/screens/categories/categories_screen.dart';
import 'package:finance_management/presentation/screens/home/home_screen.dart';
import 'package:finance_management/presentation/screens/login/login_screen.dart';
import 'package:finance_management/presentation/screens/profile/profile_screen.dart';
import 'package:finance_management/presentation/screens/sign_up/sign_up_screen.dart';
import 'package:finance_management/presentation/screens/transaction/transaction_screen.dart';
import 'package:finance_management/presentation/widgets/cubit/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:finance_management/presentation/widgets/cubit/page_view/page_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:finance_management/presentation/screens/onboarding/splash_screen.dart';
import 'package:finance_management/presentation/screens/forgetpassword/forget_password_screen.dart';
import 'package:finance_management/presentation/screens/forgetpassword/security_pin_screen.dart';
import 'package:finance_management/presentation/screens/forgetpassword/new_password_screen.dart';
import 'package:finance_management/presentation/screens/forgetpassword/password_changed_splash_screen.dart';

class BottomNavigationBarScaffold extends StatefulWidget {
  const BottomNavigationBarScaffold({super.key, required this.child});

  final Widget child;

  @override
  State<BottomNavigationBarScaffold> createState() =>
      _BottomNavigationBarScaffoldState();
}

class _BottomNavigationBarScaffoldState
    extends State<BottomNavigationBarScaffold> {
  final _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const AnalysisScreen(),
    const TransactionScreen(),
    const CategoriesScreen(),
    const ProfileScreen(),
  ];

  final List<String> _routes = [
    HomeScreen.routeName,
    AnalysisScreen.routeName,
    TransactionScreen.routeName,
    CategoriesScreen.routeName,
    ProfileScreen.routeName,
  ];

  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    final index = _getIndexFromRoute(location);
    if (index != _selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = index;
            if (_pageController.hasClients) {
              _pageController.jumpToPage(_selectedIndex);
            }
          });
        }
      });
    }
  }

  int _getIndexFromRoute(String route) {
    for (int i = 0; i < _routes.length; i++) {
      if (route == _routes[i]) {
        return i;
      }
    }

    return _selectedIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });

    context.go(_routes[index]);
  }

  void _onItemTapped(int index) {
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: SizedBox(
        height: 83,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFFFFFFFF),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 24),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart, size: 24),
                label: 'Statistics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz, size: 24), // Icon for transactions
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category, size: 24), // Icon for categories
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 24), // Icon for profile
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFFC67C4E),
            unselectedItemColor: const Color(0xFFA2A2A2),
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: SplashScreen.routeName,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: SplashScreen.routeName,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: OnboardingScreen.routeName,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: SignUpScreen.routeName,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: LoginScreen.routeName,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: ForgetPasswordScreen.routeName,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ForgetPasswordScreen(),
    ),
    GoRoute(
      path: '/security-pin-screen',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SecurityPinScreen(),
    ),
    GoRoute(
      path: '/new-password-screen',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NewPasswordScreen(),
    ),
    GoRoute(
      path: '/password-changed-splash',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const PasswordChangedSplashScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder:
          (context, state, child) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => BottomNavigationCubit()),
              BlocProvider(
                create:
                    (context) => PageViewCubit(
                      bottomNavigationCubit:
                          context.read<BottomNavigationCubit>(),
                    ),
              ),
            ],
            child: BottomNavigationBarScaffold(child: child),
          ),
      routes: [
        GoRoute(
          path: HomeScreen.routeName,
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const HomeScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  final offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
        ),
        GoRoute(
          path: AnalysisScreen.routeName,
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const AnalysisScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  final offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
        ),
        GoRoute(
          path: TransactionScreen.routeName,
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const TransactionScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  final offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
        ),
        GoRoute(
          path: CategoriesScreen.routeName,
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const CategoriesScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  final offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
        ),
        GoRoute(
          path: ProfileScreen.routeName,
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ProfileScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  final offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
        ),
      ],
    ),
  ],
);
