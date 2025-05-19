// State cho PageView
import 'package:flutter/material.dart';

class PageViewState {
  final int currentPage;
  final PageController controller;

  PageViewState({required this.currentPage, required this.controller});

  // Copy with method để tạo state mới
  PageViewState copyWith({int? currentPage, PageController? controller}) {
    return PageViewState(
      currentPage: currentPage ?? this.currentPage,
      controller: controller ?? this.controller,
    );
  }
}
