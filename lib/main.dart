import 'package:finance_management/presentation/routes.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          create: (context) =>
          TransactionBloc(TransactionRepository())..add(const LoadTransactionsEvent()),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc()..add(const LoadNotifications()),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(CategoryRepository()),
        ),
        BlocProvider<CalendarBloc>(
          create: (context) =>
          CalendarBloc(TransactionRepository())..add(const LoadCalendarTransactionsEvent()),
        ),
        BlocProvider<AnalysisBloc>(
          create: (context) => AnalysisBloc(TransactionRepository()),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(context.read<TransactionBloc>()),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(),
        ),
      ],
      child: const AppMaterial(),
    );
  }
}

class AppMaterial extends StatelessWidget {
  const AppMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}