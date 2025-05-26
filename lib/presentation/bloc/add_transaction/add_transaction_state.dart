import 'package:equatable/equatable.dart';
import 'package:finance_management/core/enum/enums.dart';
import 'package:finance_management/data/model/category_model.dart';

abstract class AddTransactionState extends Equatable {
  final DateTime selectedDate;
  final MoneyType moneyType;
  final CategoryModel? selectedCategory;
  final List<CategoryModel> availableCategories;
  final String? errorMessage;

  const AddTransactionState({
    required this.selectedDate,
    required this.moneyType,
    this.selectedCategory,
    required this.availableCategories,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    selectedDate,
    moneyType,
    selectedCategory,
    availableCategories,
    errorMessage,
  ];
}

class AddTransactionInitial extends AddTransactionState {
  const AddTransactionInitial({
    required super.selectedDate,
    required super.moneyType,
    super.selectedCategory,
    required super.availableCategories,
  });
}

class AddTransactionLoading extends AddTransactionState {
  const AddTransactionLoading({
    required super.selectedDate,
    required super.moneyType,
    super.selectedCategory,
    required super.availableCategories,
  });

  AddTransactionLoading.fromState({required AddTransactionState state})
      : super(
    selectedDate: state.selectedDate,
    moneyType: state.moneyType,
    selectedCategory: state.selectedCategory,
    availableCategories: state.availableCategories,
  );
}

class AddTransactionSuccess extends AddTransactionState {
  const AddTransactionSuccess({
    required super.selectedDate,
    required super.moneyType,
    super.selectedCategory,
    required super.availableCategories,
  });
}

class AddTransactionError extends AddTransactionState {
  const AddTransactionError({
    required super.selectedDate,
    required super.moneyType,
    super.selectedCategory,
    required super.availableCategories,
    required super.errorMessage,
  });
}