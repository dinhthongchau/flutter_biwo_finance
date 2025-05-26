import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarScreen extends StatelessWidget with CalendarScreenMixin {
  static const String routeName = '/calendar-screen';

  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarBloc, CalendarState>(
      listener: (context, state) {
        if (state is CalendarError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Unknown error')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.caribbeanGreen,
          appBar: buildHeaderCalendar(context),
          body: buildBody(state, context),
        );
      },
    );
  }

}
