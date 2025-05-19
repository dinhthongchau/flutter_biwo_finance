import 'package:finance_management/presentation/widgets/cubit/bottom_navigation/bottom_navigation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavigationCubit extends Cubit<BottomNavigationState> {
  BottomNavigationCubit() : super(const BottomNavigationState());

  void setTab(int index) {
    emit(state.copyWith(currentIndex: index));
  }
}
