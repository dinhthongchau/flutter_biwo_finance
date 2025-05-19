import 'package:finance_management/presentation/widgets/cubit/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:finance_management/presentation/widgets/cubit/page_view/page_view_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class PageViewCubit extends Cubit<PageViewState> {
  final BottomNavigationCubit bottomNavigationCubit;

  PageViewCubit({required this.bottomNavigationCubit})
    : super(PageViewState(currentPage: 0, controller: PageController())) {
    bottomNavigationCubit.stream.listen((navState) {
      if (navState.currentIndex != state.currentPage) {
        animateToPage(navState.currentIndex);
      }
    });
  }

  void animateToPage(int page) {
    state.controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    emit(state.copyWith(currentPage: page));
  }

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
