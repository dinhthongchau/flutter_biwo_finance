import 'package:finance_management/data/services/firebase_options.dart';
import 'package:finance_management/presentation/routes.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:finance_management/presentation/widgets/cubit/theme/theme_cubit.dart';
import 'package:finance_management/core/utils/notification_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (message.notification != null) {
    final chatRoomId = message.data['chatRoomId'];
    NotificationHelper.show(
      message.notification!.title ?? 'New message',
      message.notification!.body ?? '',
      chatRoomId: chatRoomId,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationHelper.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  Bloc.observer = const MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: AppProviders());
  }
}

class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>(
          create:
              (context) =>
                  TransactionBloc(TransactionRepository())
                    ..add(const LoadTransactionsEvent()),
        ),
        BlocProvider<NotificationBloc>(
          create:
              (context) => NotificationBloc()..add(const LoadNotifications()),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(CategoryRepository()),
        ),
        BlocProvider<CalendarBloc>(
          create:
              (context) =>
                  CalendarBloc(TransactionRepository())
                    ..add(const LoadCalendarTransactionsEvent()),
        ),
        BlocProvider<AnalysisBloc>(
          create: (context) => AnalysisBloc(TransactionRepository()),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(context.read<TransactionBloc>()),
        ),
        BlocProvider<HomeBloc>(create: (context) => HomeBloc()),
        BlocProvider(create: (_) => UserBloc()),
        BlocProvider(create: (_) => ThemeCubit()),
        //BlocProvider(create: (_) => NotificationBloc()),
      ],
      child: const AppMaterial(),
    );
  }
}

class AppMaterial extends StatelessWidget {
  const AppMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final chatRoomId = message.data['chatRoomId'];
      if (message.notification != null) {
        NotificationHelper.show(
          message.notification!.title ?? 'New message',
          message.notification!.body ?? '',
          chatRoomId: chatRoomId,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final chatRoomId = message.data['chatRoomId'];
      if (chatRoomId != null) {
        router.go(
          '${ProfileOnlineSupportHelperCenterScreen.routeName}?chatRoomId=$chatRoomId',
        );
      }
    });
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return SafeArea(
          child: MaterialApp.router(
            theme: theme.copyWith(
              textTheme: GoogleFonts.poppinsTextTheme(theme.textTheme),
            ),
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          ),
        );
      },
    );
  }
}
