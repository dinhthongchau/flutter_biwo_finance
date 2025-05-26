import 'package:finance_management/data/model/user_model_adapter.dart';
import 'package:finance_management/presentation/routes.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the application documents directory
  final appDocumentDir = await getApplicationDocumentsDirectory(); // Use the function directly

  Hive.init(appDocumentDir.path); // Initialize Hive with the path

  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('users');
  Bloc.observer = const MyBlocObserver();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TransactionBloc(TransactionRepository())..add(const LoadTransactionsEvent()),
          ),
          BlocProvider(
            create: (context) => NotificationBloc()..add(const LoadNotifications()),
          ),
          BlocProvider(
            create: (context) => CategoryBloc(CategoryRepository()),
          ),
          BlocProvider(
            create: (context) => CalendarBloc(TransactionRepository())..add(const LoadCalendarTransactionsEvent()),
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
          // BlocProvider<AddTransactionBloc>(
          //   create: (context) => AddTransactionBloc(),
          // ),
        ],
        child: MaterialApp.router(
          theme: ThemeData(
            textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          ),
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        ),
      ),
    );
  }
}