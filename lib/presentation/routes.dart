import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  initialLocation: LoginScreen.routeName,
  routes: [
    GoRoute(
      path: '/',
      parentNavigatorKey: _rootNavigatorKey,
      builder:
          (context, state) => const LoginScreen(
          ),
    ),
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
      path: SecurityPinScreen.routeName,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SecurityPinScreen(),
    ),
    GoRoute(
      path: NewPasswordScreen.routeName,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NewPasswordScreen(),
    ),
    GoRoute(
      path: PasswordChangedSplashScreen.routeName,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PasswordChangedSplashScreen(),
    ),
    GoRoute(
      path: ProfileEditScreen.routeName,
      builder: (context, state) {
        final userId =
            int.tryParse(state.uri.queryParameters['userId'] ?? '0') ?? 0;
        return ProfileEditScreen(userId: userId);
      },
    ),
    GoRoute(
      path: ProfileSecurityScreen.routeName,
      builder: (context, state) => const ProfileSecurityScreen(),
    ),
    GoRoute(
      path: ProfileSecurityChangePinScreen.routeName,
      builder: (context, state) => const ProfileSecurityChangePinScreen(),
    ),
    GoRoute(
      path: ProfileTermAndConditionScreen.routeName,
      builder: (context, state) => const ProfileTermAndConditionScreen(),
    ),
    GoRoute(
      path: ProfileSettingScreen.routeName,
      builder: (context, state) => const ProfileSettingScreen(),
    ),
    GoRoute(
      path: ProfileSettingNotificationScreen.routeName,
      builder: (context, state) => const ProfileSettingNotificationScreen(),
    ),
    GoRoute(
      path: ProfileSettingPasswordScreen.routeName,
      builder: (context, state) => const ProfileSettingPasswordScreen(),
    ),
    GoRoute(
      path: ProfileSettingDeleteAccountScreen.routeName,
      builder: (context, state) => const ProfileSettingDeleteAccountScreen(),
    ),
    GoRoute(
      path: ProfileSplashScreen.routeName,
      builder: (context, state) => const ProfileSplashScreen(),
    ),
    GoRoute(
      path: ProfileHelpFaqsScreen.routeName,
      builder: (context, state) => const ProfileHelpFaqsScreen(),
    ),
    GoRoute(
      path: ProfileOnlineSupportAiScreen.routeName,
      builder: (context, state) => const ProfileOnlineSupportAiScreen(),
    ),
    GoRoute(
      path: ProfileOnlineSupportAiLobbyScreen.routeName,
      builder: (context, state) => const ProfileOnlineSupportAiLobbyScreen(),
    ),
    GoRoute(
      path: ProfileOnlineSupportHelperScreen.routeName,
      builder: (context, state) => const ProfileOnlineSupportHelperScreen(),
    ),
    GoRoute(
      path: ProfileOnlineSupportHelperCenterScreen.routeName,
      builder:
          (context, state) => const ProfileOnlineSupportHelperCenterScreen(),
    ),
    GoRoute(
      path: CategoryDetailScreen.routeName,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final category = state.extra as CategoryModel?;
        if (category != null) {
          return CategoryDetailScreen(category: category);
        }
        //to test flutter inspector
        final categoryModel = CategoryModel(1, MoneyType.expense, "Food");
        return CategoryDetailScreen(category: categoryModel);
      },
    ),
    GoRoute(
      path: CategoryDetailSaveScreen.routeName,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final category = state.extra as CategoryModel?;
        if (category != null) {
          return CategoryDetailSaveScreen(category: category);
        }
        // !to test flutter inspector
        final categoryModel = CategoryModel(1, MoneyType.expense, "Food");
        return CategoryDetailSaveScreen(category: categoryModel);
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
                      notificationsScreenPath:
                      '${HomeScreen.routeName}${NotificationScreen.routeName}',
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
                      child: CategoryListScreen(
                        moneyType: moneyType ?? MoneyType.expense,
                      ),
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
              pageBuilder: (context, state) {
                final userState = context.read<UserBloc>().state;
                if (userState is UserLoaded) {
                  return NoTransitionPage(
                    child: ProfileScreen(userId: userState.user.id),
                  );
                }
                return const NoTransitionPage(
                  child: ProfileScreen(userId: '0'),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
