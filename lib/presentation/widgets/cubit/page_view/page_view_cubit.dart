
import 'package:finance_management/presentation/widgets/cubit/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:finance_management/presentation/widgets/cubit/page_view/page_view_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class PageViewCubit extends Cubit<PageViewState> {
  final BottomNavigationCubit bottomNavigationCubit;

  PageViewCubit({required this.bottomNavigationCubit})
    : super(PageViewState(currentPage: 0, controller: PageController())) {
    // Lắng nghe sự thay đổi từ BottomNavigationCubit
    bottomNavigationCubit.stream.listen((navState) {
      if (navState.currentIndex != state.currentPage) {
        animateToPage(navState.currentIndex);
      }
    });
  }

  // Chuyển trang với animation
  void animateToPage(int page) {
    state.controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    emit(state.copyWith(currentPage: page));
  }

  // Xử lý khi người dùng vuốt để chuyển trang
  void onPageChanged(int page) {
    emit(state.copyWith(currentPage: page));
    bottomNavigationCubit.setTab(page);
  }

  @override
  Future<void> close() {
    state.controller.dispose();
    return super.close();
  }
}
