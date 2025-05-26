
import 'dart:async';

import 'package:finance_management/core/enum/enums.dart';
import 'package:finance_management/core/utils/common_functions.dart';
import 'package:finance_management/presentation/bloc/home/home_event.dart';
import 'package:finance_management/presentation/bloc/home/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial(selectedTimeFilter: TimeFilterHome.monthly)) {
    on<SelectTimeFilterEvent>(_onSelectTimeFilter);
  }

  Future<void> _onSelectTimeFilter(
      SelectTimeFilterEvent event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoading.fromState(state: state));
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(HomeSuccess(selectedTimeFilter: event.timeFilter));
    } catch (e, stackTrace) {
      String errorMessage = e is TimeoutException
          ? 'Request timed out: ${e.message}'
          : 'Unknown error: ${e.toString()}';
      customPrint('Stack trace: $stackTrace');
      emit(HomeError(
        selectedTimeFilter: state.selectedTimeFilter,
        errorMessage: errorMessage,
      ));
    }
  }
}