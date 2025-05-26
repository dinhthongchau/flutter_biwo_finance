export 'package:finance_management/data/model/category_model.dart';
export 'package:finance_management/presentation/screens/analysis/analysis/analysis_screen.dart';
export 'package:finance_management/presentation/screens/analysis/calendar/calendar_screen.dart';
export 'package:finance_management/presentation/screens/analysis/search/search_screen.dart';
export 'package:finance_management/presentation/screens/categories/add_transaction/add_transaction_screen.dart';
export 'package:finance_management/presentation/screens/categories/category_list/categories_screen.dart';
export 'package:finance_management/presentation/screens/categories/category_detail/category_detail_screen.dart';
export 'package:finance_management/presentation/screens/categories/category_list/category_list_screen.dart';
export 'package:finance_management/presentation/screens/forget_password/forget_password_screen.dart';
export 'package:finance_management/presentation/screens/forget_password/new_password_screen.dart';
export 'package:finance_management/presentation/screens/forget_password/password_changed_splash_screen.dart';
export 'package:finance_management/presentation/screens/forget_password/security_pin_screen.dart';
export 'package:finance_management/presentation/screens/login/login_screen.dart';
export 'package:finance_management/presentation/screens/notification/notification_screen.dart';
export 'package:finance_management/presentation/screens/onboarding/splash_screen.dart';
export 'package:finance_management/presentation/screens/profile/profile_screen.dart';
export 'package:finance_management/presentation/screens/sign_up/sign_up_screen.dart';
export 'package:finance_management/presentation/screens/transaction/transaction_screen.dart';
export 'package:finance_management/presentation/widgets/bottom_navigation_bar_scaffold.dart'; // export BottomNavigationBarScaffold
export 'package:finance_management/data/repositories/category_repository.dart';
export 'package:finance_management/core/utils/common_functions.dart';
export 'package:finance_management/data/model/transaction_model.dart';
export 'package:finance_management/gen/assets.gen.dart';
export 'package:finance_management/presentation/bloc/transaction/transaction_bloc.dart';
export 'package:finance_management/presentation/bloc/transaction/transaction_event.dart';
export 'package:finance_management/presentation/bloc/transaction/transaction_state.dart';
export 'package:finance_management/presentation/screens/transaction/transaction_reused_widgets.dart';
export 'package:finance_management/presentation/widgets/widget/app_colors.dart';
export 'package:finance_management/presentation/widgets/widget/text_styles.dart';
export 'package:finance_management/data/model/user_model.dart';
export 'package:finance_management/data/repositories/transaction_repository.dart';
export 'package:finance_management/presentation/bloc/notification/notification_event.dart';
export 'package:finance_management/presentation/bloc/notification/notification_state.dart';
export 'package:finance_management/presentation/bloc/notification/notification_bloc.dart';
export 'package:finance_management/presentation/screens/categories/category_detail/category_detail_save_screen.dart';
export 'package:finance_management/core/enum/enums.dart';
export  'package:finance_management/presentation/widgets/build_app_bar.dart';
export 'package:finance_management/presentation/bloc/calendar/calendar_bloc.dart';
export 'package:finance_management/presentation/bloc/calendar/calendar_event.dart';
export 'package:finance_management/presentation/bloc/calendar/calendar_state.dart';
export 'package:finance_management/data/model/notification_model.dart';
export 'package:finance_management/data/model/analysis_model.dart';
 export 'package:finance_management/presentation/bloc/category/category_bloc.dart';
// export 'package:finance_management/presentation/bloc/category/category_state.dart';
// export 'package:finance_management/presentation/bloc/category/category_event.dart';
export 'package:finance_management/presentation/bloc/analysis/analysis_bloc.dart';
export 'package:finance_management/presentation/bloc/analysis/analysis_event.dart';
export 'package:finance_management/presentation/bloc/analysis/analysis_state.dart';
export 'package:finance_management/presentation/bloc/search/search_bloc.dart';
export 'package:finance_management/presentation/bloc/search/search_event.dart';
export 'package:finance_management/presentation/bloc/search/search_state.dart';
export 'package:finance_management/presentation/bloc/add_transaction/add_transaction_bloc.dart';
export 'package:finance_management/presentation/bloc/add_transaction/add_transaction_state.dart';
export 'package:finance_management/presentation/bloc/add_transaction/add_transaction_event.dart';
export 'package:finance_management/presentation/bloc/home/home_bloc.dart';
export 'package:finance_management/presentation/bloc/home/home_state.dart';
export 'package:finance_management/presentation/bloc/home/home_event.dart';
export 'package:finance_management/presentation/bloc/bloc_observe.dart';
/*
Tách theo tính năng/feature, không gom tất cả vào 1 file:

shared_widgets.dart, shared_blocs.dart, shared_utils.dart, shared_screens.dart.

Không export các thư viện lớn như intl.dart, flutter/material.dart, go_router.dart trong barrel chung.

Chỉ export các phần do bạn kiểm soát (source code trong project), không export package bên thứ ba trừ khi cần thiết.

   */
