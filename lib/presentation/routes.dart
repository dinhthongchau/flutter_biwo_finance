import 'package:finance_management/gen/assets.gen.dart';
import 'package:finance_management/presentation/screens/analysis/analysis_screen.dart';
import 'package:finance_management/presentation/screens/categories/categories_screen.dart';
import 'package:finance_management/presentation/screens/authentication/forget_password/forget_password_screen.dart';
import 'package:finance_management/presentation/screens/authentication/forget_password/new_password_screen.dart';
import 'package:finance_management/presentation/screens/authentication/forget_password/password_changed_splash_screen.dart';
import 'package:finance_management/presentation/screens/authentication/forget_password/security_pin_screen.dart';
import 'package:finance_management/presentation/screens/home/home_screen.dart';
import 'package:finance_management/presentation/screens/authentication/login/login_screen.dart';
import 'package:finance_management/presentation/screens/notification/notification_screen.dart';
import 'package:finance_management/presentation/screens/onboarding/splash_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_main/profile_screen.dart';
import 'package:finance_management/presentation/screens/authentication/sign_up/sign_up_screen.dart';
import 'package:finance_management/presentation/screens/transaction/transaction_screen.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_management/presentation/bloc/user/user_bloc.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_main/profile_edit_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_security/profile_security_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_security/profile_security_change_pin_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_security/profile_term_and_condition.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_setting/profile_setting_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_setting/profile_setting_notification_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_setting/profile_setting_password_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_main/profile_splash_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_setting/profile_setting_delete_account_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_help/profile_help_faqs_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_help/profile_online_support_ai_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_help/profile_online_support_ai_lobby.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_help/profile_online_support_helper_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_help/profile_online_support_helper_center_screen.dart';

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
      builder:
          (context, state, child) => BottomNavigationBarScaffold(child: child),
      routes: [
        GoRoute(
          path: HomeScreen.routeName,
          pageBuilder:
              (context, state) => const NoTransitionPage(
                child: HomeScreen(
                  label: 'Home',
                  detailsPath: '/home-screen/notifications',
                ),
              ),
          routes: [
            GoRoute(
              path: NotificationScreen.routeName,
              builder: (context, state) => const NotificationScreen(),
            ),
          ],
        ),
        GoRoute(
          path: AnalysisScreen.routeName,
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: AnalysisScreen()),
        ),
        GoRoute(
          path: TransactionScreen.routeName,
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: TransactionScreen()),
        ),
        GoRoute(
          path: CategoriesScreen.routeName,
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: CategoriesScreen()),
        ),
        GoRoute(
          path: ProfileScreen.routeName,
          pageBuilder: (context, state) {
            final userState = context.read<UserBloc>().state;
            if (userState is UserLoaded) {
              return NoTransitionPage(
                child: ProfileScreen(userId: userState.user.id),
              );
            }
            // Nếu chưa đăng nhập, có thể chuyển về login hoặc show loading
            return const NoTransitionPage(child: ProfileScreen(userId: '0'));
          },
        ),
        GoRoute(
          path: '/profile-edit-screen',
          builder: (context, state) {
            final userId =
                int.tryParse(state.uri.queryParameters['userId'] ?? '0') ?? 0;
            return ProfileEditScreen(userId: userId);
          },
        ),
        GoRoute(
          path: '/profile-security-screen',
          builder: (context, state) => const ProfileSecurityScreen(),
        ),
        GoRoute(
          path: '/profile-security-change-pin',
          builder: (context, state) => const ProfileSecurityChangePinScreen(),
        ),
        GoRoute(
          path: '/profile-term-and-condition',
          builder: (context, state) => const ProfileTermAndConditionScreen(),
        ),
        GoRoute(
          path: '/profile-setting-screen',
          builder: (context, state) => const ProfileSettingScreen(),
        ),
        GoRoute(
          path: '/profile-setting-notification',
          builder: (context, state) => const ProfileSettingNotificationScreen(),
        ),
        GoRoute(
          path: '/profile-setting-password',
          builder: (context, state) => const ProfileSettingPasswordScreen(),
        ),
        GoRoute(
          path: '/profile-setting-delete-account',
          builder:
              (context, state) => const ProfileSettingDeleteAccountScreen(),
        ),
        GoRoute(
          path: '/profile-splash',
          builder: (context, state) => const ProfileSplashScreen(),
        ),
        GoRoute(
          path: '/profile-help-faqs',
          builder: (context, state) => const ProfileHelpFaqsScreen(),
        ),
        GoRoute(
          path: '/profile-online-support-ai',
          builder: (context, state) => const ProfileOnlineSupportAiScreen(),
        ),
        GoRoute(
          path: '/profile-online-support-ai-lobby',
          builder:
              (context, state) => const ProfileOnlineSupportAiLobbyScreen(),
        ),
        GoRoute(
          path: '/profile-online-support-helper',
          builder: (context, state) => const ProfileOnlineSupportHelperScreen(),
        ),
        GoRoute(
          path: '/profile-online-support-helper-center',
          builder:
              (context, state) =>
                  const ProfileOnlineSupportHelperCenterScreen(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}

class BottomNavigationBarScaffold extends StatefulWidget {
  const BottomNavigationBarScaffold({super.key, required this.child});
  final Widget child;

  @override
  State<BottomNavigationBarScaffold> createState() =>
      BottomNavigationBarScaffoldState();
}

class BottomNavigationBarScaffoldState
    extends State<BottomNavigationBarScaffold> {
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
            _buildNavItem(0, Assets.bottomNavigationIcon.homeSvg.path),
            _buildNavItem(1, Assets.bottomNavigationIcon.analysisSvg.path),
            _buildNavItem(2, Assets.bottomNavigationIcon.transactions.path),
            _buildNavItem(3, Assets.bottomNavigationIcon.categorySvg.path),
            _buildNavItem(4, Assets.bottomNavigationIcon.profileSvg.path),
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
          color:
              _selectedIndex == index
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
