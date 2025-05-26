
import 'package:finance_management/core/enum/enums.dart';
import 'package:finance_management/presentation/bloc/home/home_event.dart';
import 'package:finance_management/presentation/bloc/home/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc()
      : super(const HomeInitial(selectedTimeFilter: TimeFilterHome.monthly)) {
    on<SelectTimeFilterEvent>(_onSelectTimeFilter);
  }

  void _onSelectTimeFilter(SelectTimeFilterEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(selectedTimeFilter: event.timeFilter));
  }
}