import 'package:equatable/equatable.dart';
import 'package:finance_management/presentation/shared_data.dart';

abstract class SearchState extends Equatable {
  final List<TransactionModel>? filteredTransactions;
  final CategoryModel? selectedCategory;
  final DateTime? selectedDate;
  final ReportTypeSearch? selectedReportType;
  final List<CategoryModel> allCategories;
  final String? errorMessage;

  const SearchState({
    this.filteredTransactions,
    this.selectedCategory,
    this.selectedDate,
    this.selectedReportType,
    required this.allCategories,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    filteredTransactions,
    selectedCategory,
    selectedDate,
    selectedReportType,
    allCategories,
    errorMessage,
  ];
}

class SearchInitial extends SearchState {
  const SearchInitial({
    super.filteredTransactions,
    super.selectedCategory,
    super.selectedDate,
    super.selectedReportType,
    required super.allCategories,
  });
}

class SearchLoading extends SearchState {
  const SearchLoading({
    super.filteredTransactions,
    super.selectedCategory,
    super.selectedDate,
    super.selectedReportType,
    required super.allCategories,
  });

  SearchLoading.fromState({required SearchState state})
      : super(
    filteredTransactions: state.filteredTransactions,
    selectedCategory: state.selectedCategory,
    selectedDate: state.selectedDate,
    selectedReportType: state.selectedReportType,
    allCategories: state.allCategories,
  );
}

class SearchSuccess extends SearchState {
  const SearchSuccess({
    super.filteredTransactions,
    super.selectedCategory,
    super.selectedDate,
    super.selectedReportType,
    required super.allCategories,
  });
}

class SearchError extends SearchState {
  const SearchError({
    super.filteredTransactions,
    super.selectedCategory,
    super.selectedDate,
    super.selectedReportType,
    required super.allCategories,
    required String super.errorMessage,
  });
}