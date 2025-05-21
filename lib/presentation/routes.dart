import 'package:finance_management/presentation/screens/analysis/analysis_screen.dart';
import 'package:finance_management/presentation/screens/categories/categories_screen.dart';
import 'package:finance_management/presentation/screens/forget_password/forget_password_screen.dart';
import 'package:finance_management/presentation/screens/forget_password/new_password_screen.dart';
import 'package:finance_management/presentation/screens/forget_password/password_changed_splash_screen.dart';
import 'package:finance_management/presentation/screens/forget_password/security_pin_screen.dart';
import 'package:finance_management/presentation/screens/home/home_screen.dart';
import 'package:finance_management/presentation/screens/login/login_screen.dart';
import 'package:finance_management/presentation/screens/notification/notification_screen.dart';
import 'package:finance_management/presentation/screens/onboarding/splash_screen.dart';
import 'package:finance_management/presentation/screens/profile/profile_screen.dart';
import 'package:finance_management/presentation/screens/sign_up/sign_up_screen.dart';
import 'package:finance_management/presentation/screens/transaction/transaction_screen.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: SplashScreen.routeName,
  routes: [
    GoRoute(
      path: SplashScreen.routeName,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: SignUpScreen.routeName,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: LoginScreen.routeName,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: ForgetPasswordScreen.routeName,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ForgetPasswordScreen(),
    ),
    GoRoute(
      path: '/security-pin-screen',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SecurityPinScreen(),
    ),
    GoRoute(
      path: '/new-password-screen',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NewPasswordScreen(),
    ),
    GoRoute(
      path: '/password-changed-splash',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PasswordChangedSplashScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => BottomNavigationBarScaffold(child: child),
      routes: [
        GoRoute(
          path: HomeScreen.routeName,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(label: 'Home', detailsPath: '/home-screen/notifications'),
          ),
          routes: [
            GoRoute(
              path: 'notifications',
              builder: (context, state) => const NotificationScreen(label: 'Home'),
            ),
          ],
        ),
        GoRoute(
          path: AnalysisScreen.routeName,
          pageBuilder: (context, state) => const NoTransitionPage(child: AnalysisScreen()),
        ),
        GoRoute(
          path: TransactionScreen.routeName,
          pageBuilder: (context, state) => const NoTransitionPage(child: TransactionScreen()),
        ),
        GoRoute(
          path: CategoriesScreen.routeName,
          pageBuilder: (context, state) => const NoTransitionPage(child: CategoriesScreen()),
        ),
        GoRoute(
          path: ProfileScreen.routeName,
          pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}

class BottomNavigationBarScaffold extends StatefulWidget {
  const BottomNavigationBarScaffold({super.key, required this.child});
  final Widget child;

  @override
  State<BottomNavigationBarScaffold> createState() => BottomNavigationBarScaffoldState();
}

class BottomNavigationBarScaffoldState extends State<BottomNavigationBarScaffold> {
  final _routes = [
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
    final index = _routes.indexWhere(
          (route) => location == route || location.startsWith('$route/'),
    );
    if (index != -1 && index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_routes[index]);
  }

  void goToNotifications() {
    // Navigate to notifications without changing the selected index
    context.push('/home-screen/notifications');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.honeydew,
      child: Scaffold(
        body: widget.child,
        backgroundColor: Colors.transparent,
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(70.0),
          topRight: Radius.circular(70.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          left: 25,
          right: 25,
          bottom: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'assets/BottomNavigationIcon/Home.svg'),
            _buildNavItem(1, 'assets/BottomNavigationIcon/Analysis.svg'),
            _buildNavItem(2, 'assets/BottomNavigationIcon/Transactions.svg'),
            _buildNavItem(3, 'assets/BottomNavigationIcon/Category.svg'),
            _buildNavItem(4, 'assets/BottomNavigationIcon/Profile.svg'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.only(
          top: 10,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? AppColors.caribbeanGreen
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: SvgPicture.asset(
          iconPath,
          width: index == 2 ? 27 : 22,
          height: 27,
        ),
      ),
    );
  }
}

