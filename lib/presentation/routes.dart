import 'package:finance_management/presentation/screens/analysis/analysis_screen.dart';
import 'package:finance_management/presentation/screens/categories/categories_screen.dart';
import 'package:finance_management/presentation/screens/home/home_screen.dart';
import 'package:finance_management/presentation/screens/login/login_screen.dart';
import 'package:finance_management/presentation/screens/profile/profile_screen.dart';
import 'package:finance_management/presentation/screens/sign_up/sign_up_screen.dart';
import 'package:finance_management/presentation/screens/transaction/transaction_screen.dart';
import 'package:finance_management/presentation/widgets/cubit/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:finance_management/presentation/widgets/cubit/page_view/page_view_cubit.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

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
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.only(top: 0),
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
            GestureDetector(
              onTap: () => _onItemTapped(0),
              child: Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      _selectedIndex == 0
                          ? AppColors.caribbeanGreen
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: SvgPicture.asset(
                  'assets/BottomNavigationIcon/Home.svg',
                  width: 22,
                  height: 27,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(1),
              child: Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      _selectedIndex == 1
                          ? AppColors.caribbeanGreen
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: SvgPicture.asset(
                  'assets/BottomNavigationIcon/Analysis.svg',
                  width: 22,
                  height: 27,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      _selectedIndex == 2
                          ? AppColors.caribbeanGreen
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: SvgPicture.asset(
                  'assets/BottomNavigationIcon/Transactions.svg',
                  width: 27,
                  height: 27,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(3),
              child: Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      _selectedIndex == 3
                          ? AppColors.caribbeanGreen
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: SvgPicture.asset(
                  'assets/BottomNavigationIcon/Category.svg',
                  width: 22,
                  height: 27,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(4),
              child: Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      _selectedIndex == 4
                          ? AppColors.caribbeanGreen
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: SvgPicture.asset(
                  'assets/BottomNavigationIcon/Profile.svg',
                  width: 22,
                  height: 27,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: HomeScreen.routeName,
  debugLogDiagnostics: true,
  routes: [
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
