
import 'package:finance_management/presentation/widgets/cubit/bottom_navigation/bottom_navigation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// State cho bottom navigation

// Cubit để quản lý bottom navigation
class BottomNavigationCubit extends Cubit<BottomNavigationState> {
  BottomNavigationCubit() : super(const BottomNavigationState());

  // Thay đổi tab
  void setTab(int index) {
    emit(state.copyWith(currentIndex: index));
  }
}
