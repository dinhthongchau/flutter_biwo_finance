import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_management/data/model/category_model.dart';
import 'package:finance_management/presentation/shared_data.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc(this.categoryRepository) : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<AddCategory>(_onAddCategory);
  }

  Future<void> _onLoadCategories(
      LoadCategories event,
      Emitter<CategoryState> emit,
      ) async {
    emit(const CategoryLoading());
    try {
      final categories = await categoryRepository.getCategoriesByMoneyType(event.moneyType);
      if (categories.isEmpty) {
        throw Exception('No categories found');
      }
      emit(CategorySuccess(categories: categories));
    } catch (e, stackTrace) {
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = 'Request timed out: ${e.message}';
      } else {
        errorMessage = 'Unknown error: ${e.toString()}';
      }
      debugPrint('Stack trace: $stackTrace');
      emit(CategoryError(errorMessage: errorMessage));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event,
      Emitter<CategoryState> emit,
      ) async {
    emit(CategoryLoading.fromState(state: state));
    try {
      await categoryRepository.updateCategory(event.category);
      final updatedCategories = List<CategoryModel>.from(state.categories)
        ..removeWhere((c) => c.id == event.category.id)
        ..add(event.category);
      emit(CategorySuccess(categories: updatedCategories));
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to update category: ${e.toString()}';
      debugPrint('Stack trace: $stackTrace');
      emit(CategoryError(errorMessage: errorMessage));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event,
      Emitter<CategoryState> emit,
      ) async {
    emit(CategoryLoading.fromState(state: state));
    try {
      await categoryRepository.deleteCategory(event.categoryId);
      final updatedCategories = List<CategoryModel>.from(state.categories)
        ..removeWhere((c) => c.id == event.categoryId);
      emit(CategorySuccess(categories: updatedCategories));
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to delete category: ${e.toString()}';
      debugPrint('Stack trace: $stackTrace');
      emit(CategoryError(errorMessage: errorMessage));
    }
  }
  Future<void> _onAddCategory(
      AddCategory event,
      Emitter<CategoryState> emit,
      ) async {
    emit(CategoryLoading.fromState(state: state));
    try {
      await categoryRepository.addCategory(
        event.category.categoryType,
        event.category.moneyType,
        goalSave: event.category.goalSave,
      );
      final updatedCategories = List<CategoryModel>.from(state.categories)
        ..add(event.category);
      emit(CategorySuccess(categories: updatedCategories));
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to add category: ${e.toString()}';
      debugPrint('Stack trace: $stackTrace');
      emit(CategoryError(errorMessage: errorMessage));
    }
  }
}