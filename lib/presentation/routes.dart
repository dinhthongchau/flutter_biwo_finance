

import 'package:finance_management/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; //tesst
import 'package:finance_management/presentation/shared_data.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellHome',
);
final _shellNavigatorAnalysisKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellAnalysis',
);
final _shellNavigatorTransactionKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellTransaction',
);
final _shellNavigatorCategoriesKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellCategories',
);
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellProfile',
);

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: HomeScreen.routeName,
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
    GoRoute(
      path: CategoryDetailScreen.routeName,
      name: CategoryDetailScreen.routeName,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final category = state.extra as CategoryModel?;
        if (category != null) {
          return CategoryDetailScreen(category: category);
        }
        return const Scaffold(
          body: Center(
            child: Text(
              'Error: Category details not provided for detail screen.',
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: CategoryDetailSaveScreen.routeName,
      name: CategoryDetailSaveScreen.routeName,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final category = state.extra as CategoryModel?;
        if (category != null) {
          return CategoryDetailSaveScreen(category: category);
        }
        return const Scaffold(
          body: Center(
            child: Text(
              'Error: Category details not provided for detail saving screen.',
            ),
          ),
        );
      },
    ),

    GoRoute(
      path: AddTransactionScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        CategoryModel? selectedCategory;
        MoneyType? moneyType;

        if (state.extra is CategoryModel) {
          selectedCategory = state.extra as CategoryModel;
        } else if (state.extra is MoneyType) {
          moneyType = state.extra as MoneyType;
        }

        return AddTransactionScreen(
          initialSelectedCategory: selectedCategory,
          initialMoneyType: moneyType,
        );
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavigationBarScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: HomeScreen.routeName,
              pageBuilder:
                  (context, state) => const NoTransitionPage(
                    child: HomeScreen(
                      label: 'Home',
                      notificationsScreenPath:
                          '/home-screen/notifications-screen',
                    ),
                  ),
              routes: [
                GoRoute(
                  path: NotificationScreen.routeName,
                  builder: (context, state) => const NotificationScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAnalysisKey,
          routes: [
            GoRoute(
              path: AnalysisScreen.routeName,
              pageBuilder:
                  (context, state) => const NoTransitionPage(
                    child: AnalysisScreen(
                      searchScreenPath: '/analysis-screen/search-screen',
                      calendarScreenPath: '/analysis-screen/calendar-screen',
                    ),
                  ),
              routes: [
                GoRoute(
                  path: SearchScreen.routeName,
                  pageBuilder:
                      (context, state) =>
                          const NoTransitionPage(child: SearchScreen()),
                ),
                GoRoute(
                  path: CalendarScreen.routeName,
                  pageBuilder:
                      (context, state) =>
                          const NoTransitionPage(child: CalendarScreen()),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorTransactionKey,
          routes: [
            GoRoute(
              path: TransactionScreen.routeName,
              pageBuilder:
                  (context, state) =>
                      const NoTransitionPage(child: TransactionScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorCategoriesKey,
          routes: [
            GoRoute(
              path: CategoriesScreen.routeName,
              pageBuilder:
                  (context, state) => const NoTransitionPage(
                    child: CategoriesScreen(
                      categoriesScreenPath:
                          '/categories-screen/category-list-screen',
                    ),
                  ),
              routes: [
                GoRoute(
                  path: CategoryListScreen.routeName,
                  pageBuilder: (context, state) {
                    final moneyType = state.extra as MoneyType?;
                    return NoTransitionPage(
                      child: CategoryListScreen(moneyType: moneyType!),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: ProfileScreen.routeName,
              pageBuilder:
                  (context, state) =>
                      const NoTransitionPage(child: ProfileScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);
