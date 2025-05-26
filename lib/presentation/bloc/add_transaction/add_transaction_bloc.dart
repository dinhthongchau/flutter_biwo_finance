import 'package:collection/collection.dart';
import 'package:finance_management/core/enum/enums.dart';
import 'package:finance_management/data/model/category_model.dart';
import 'package:finance_management/data/repositories/category_repository.dart';
import 'package:finance_management/presentation/bloc/add_transaction/add_transaction_event.dart';
import 'package:finance_management/presentation/bloc/add_transaction/add_transaction_state.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddTransactionBloc extends Bloc<AddTransactionNewEvent, AddTransactionState> {
  AddTransactionBloc({
    required MoneyType initialMoneyType,
    CategoryModel? initialSelectedCategory,
  }) : super(AddTransactionInitial(
    selectedDate: DateTime.now(),
    moneyType: initialMoneyType,
    selectedCategory: initialSelectedCategory,
    availableCategories: [],
  )) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<SelectDateEvent>(_onSelectDate);
    on<SelectCategoryEvent>(_onSelectCategory);
  }

  Future<void> _onLoadCategories(
      LoadCategoriesEvent event,
      Emitter<AddTransactionState> emit,
      ) async {
    emit(AddTransactionLoading.fromState(state: state));
    try {
      final moneyType = event.initialSelectedCategory?.moneyType ?? state.moneyType;
      final categories = await CategoryRepository().getCategoriesByMoneyType(moneyType);
      CategoryModel? selectedCategory;
      if (event.initialSelectedCategory != null &&
          event.initialSelectedCategory!.moneyType == moneyType) {
        selectedCategory = categories.firstWhereOrNull(
              (cat) => cat.id == event.initialSelectedCategory!.id,
        ) ?? event.initialSelectedCategory;
      }
      emit(AddTransactionSuccess(
        selectedDate: state.selectedDate,
        moneyType: moneyType,
        selectedCategory: selectedCategory,
        availableCategories: categories,
      ));
    } catch (e) {
      String errorMessage = 'Failed to load categories: ${e.toString()}';
      emit(AddTransactionError(
        selectedDate: state.selectedDate,
        moneyType: state.moneyType,
        selectedCategory: state.selectedCategory,
        availableCategories: state.availableCategories,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onSelectDate(
      SelectDateEvent event,
      Emitter<AddTransactionState> emit,
      ) async {
    final DateTime? picked = await showDatePicker(
      context: event.context,
      initialDate: state.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.caribbeanGreen,
              onPrimary: AppColors.fenceGreen,
              onSurface: AppColors.blackHeader,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.caribbeanGreen,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != state.selectedDate) {
      emit(AddTransactionSuccess(
        selectedDate: picked,
        moneyType: state.moneyType,
        selectedCategory: state.selectedCategory,
        availableCategories: state.availableCategories,
      ));
    }
  }

  void _onSelectCategory(
      SelectCategoryEvent event,
      Emitter<AddTransactionState> emit,
      ) {
    emit(AddTransactionSuccess(
      selectedDate: state.selectedDate,
      moneyType: state.moneyType,
      selectedCategory: event.category,
      availableCategories: state.availableCategories,
    ));
  }
}