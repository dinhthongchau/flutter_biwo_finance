import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:finance_management/presentation/widgets/cubit/theme/theme_dark.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(ThemeData.light());

  void toggleTheme(bool isDark) {
    if (isDark) {
      emit(darkTheme);
    } else {
      emit(ThemeData.light());
    }
  }
}
