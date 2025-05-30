import 'package:equatable/equatable.dart';
import 'package:finance_management/core/enum/enums.dart';
import 'package:finance_management/data/model/transaction/category_model.dart';

abstract class AddTransactionState extends Equatable {
  final DateTime selectedDate;
  final MoneyType moneyType;
  final CategoryModel? selectedCategory;
  final List<CategoryModel> availableCategories;


  const AddTransactionState({
    required this.selectedDate,
    required this.moneyType,
    this.selectedCategory,
    required this.availableCategories,
  });

  @override
  List<Object?> get props => [
    selectedDate,
    moneyType,
    selectedCategory,
    availableCategories,
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
  final String? errorMessage;
  const AddTransactionError({
    required super.selectedDate,
    required super.moneyType,
    super.selectedCategory,
    required super.availableCategories,
    required this.errorMessage,
  });
}