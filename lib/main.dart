import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:finance_management/presentation/bloc/bloc_observe.dart';
import 'package:finance_management/presentation/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finance_management/presentation/bloc/user/user_bloc.dart';
import 'package:finance_management/presentation/widgets/cubit/theme/theme_cubit.dart';
import 'package:finance_management/utils/notification_helper.dart';
import 'package:finance_management/presentation/bloc/notification/notification_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
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
  await Firebase.initializeApp();
  await NotificationHelper.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  Bloc.observer = MyBlocObserver();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => UserBloc()),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => NotificationBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe FCM khi app foreground
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
    // Lắng nghe khi user bấm vào notification (background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final chatRoomId = message.data['chatRoomId'];
      if (chatRoomId != null) {
        router.go(
          '/profile-online-support-helper-center?chatRoomId=$chatRoomId',
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
