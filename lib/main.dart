import 'package:finance_management/data/model/user_model.dart';
import 'package:finance_management/data/model/user_model_adapter.dart';
import 'package:finance_management/data/repositories/transaction_repository.dart';
import 'package:finance_management/presentation/bloc/bloc_observe.dart';
import 'package:finance_management/presentation/bloc/notification/notification_bloc.dart';
import 'package:finance_management/presentation/bloc/notification/notification_event.dart';
import 'package:finance_management/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:finance_management/presentation/bloc/transaction/transaction_event.dart';
import 'package:finance_management/presentation/routes.dart';
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
  Bloc.observer = MyBlocObserver();
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