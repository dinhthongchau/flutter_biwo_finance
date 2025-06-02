import 'package:equatable/equatable.dart';
import 'package:finance_management/presentation/shared_data.dart';
abstract class TransactionState extends Equatable {
  final List<TransactionModel> allTransactions;
  final String selectedMonth;
  final List<String> availableMonths;
  final MoneyType? currentListFilterType;
  final Map<String, int> financialsForSummary; // totalBalance, income, expense, save


  const TransactionState({
    this.allTransactions = const [],
    this.selectedMonth = 'All',
    this.availableMonths = const ['All'],
    this.currentListFilterType,
    this.financialsForSummary = const {
      'totalBalance': 0,
      'income': 0,
      'expense': 0,
      'save': 0,
    },
  });

  @override
  List<Object?> get props => [
    allTransactions,
    selectedMonth,
    availableMonths,
    currentListFilterType,
    financialsForSummary,
  ];

  TransactionState copyWith({
    List<TransactionModel>? allTransactions,
    String? selectedMonth,
    List<String>? availableMonths,
    MoneyType? currentListFilterType,
    Map<String, int>? financialsForSummary,
    String? errorMessage,
  });
}

class TransactionInitial extends TransactionState {
  const TransactionInitial({
    super.allTransactions,
    super.selectedMonth,
    super.availableMonths,
    super.currentListFilterType,
    super.financialsForSummary,
  });

  @override
  List<Object?> get props => [
    allTransactions,
    selectedMonth,
    availableMonths,
    currentListFilterType,
    financialsForSummary,
  ];

  @override
  TransactionInitial copyWith({
    List<TransactionModel>? allTransactions,
    String? selectedMonth,
    List<String>? availableMonths,
    MoneyType? currentListFilterType,
    Map<String, int>? financialsForSummary,
    String? errorMessage,
  }) {
    return TransactionInitial(
      allTransactions: allTransactions ?? this.allTransactions,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      availableMonths: availableMonths ?? this.availableMonths,
      currentListFilterType: currentListFilterType ?? this.currentListFilterType,
      financialsForSummary: financialsForSummary ?? this.financialsForSummary,
    );
  }
}

class TransactionLoading extends TransactionState {
  const TransactionLoading({
    super.allTransactions,
    super.selectedMonth,
    super.availableMonths,
    super.currentListFilterType,
    super.financialsForSummary,
  });

  TransactionLoading.fromState({required TransactionState state})
      : super(
    allTransactions: state.allTransactions,
    selectedMonth: state.selectedMonth,
    availableMonths: state.availableMonths,
    currentListFilterType: state.currentListFilterType,
    financialsForSummary: state.financialsForSummary,
  );
  
  @override
  List<Object?> get props => [
    allTransactions,
    selectedMonth,
    availableMonths,
    currentListFilterType,
    financialsForSummary,
  ];

  @override
  TransactionLoading copyWith({
    List<TransactionModel>? allTransactions,
    String? selectedMonth,
    List<String>? availableMonths,
    MoneyType? currentListFilterType,
    Map<String, int>? financialsForSummary,
    String? errorMessage,
  }) {
    return TransactionLoading(
      allTransactions: allTransactions ?? this.allTransactions,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      availableMonths: availableMonths ?? this.availableMonths,
      currentListFilterType: currentListFilterType ?? this.currentListFilterType,
      financialsForSummary: financialsForSummary ?? this.financialsForSummary,
    );
  }
}

class TransactionSuccess extends TransactionState {
  const TransactionSuccess({
    required super.allTransactions,
    required super.selectedMonth,
    required super.availableMonths,
    required super.currentListFilterType,
    required super.financialsForSummary,
  });
  
  @override
  List<Object?> get props => [
    allTransactions,
    selectedMonth,
    availableMonths,
    currentListFilterType,
    financialsForSummary,
  ];

  @override
  TransactionSuccess copyWith({
    List<TransactionModel>? allTransactions,
    String? selectedMonth,
    List<String>? availableMonths,
    MoneyType? currentListFilterType,
    Map<String, int>? financialsForSummary,
    String? errorMessage,
  }) {
    return TransactionSuccess(
      allTransactions: allTransactions ?? this.allTransactions,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      availableMonths: availableMonths ?? this.availableMonths,
      currentListFilterType: currentListFilterType ?? this.currentListFilterType,
      financialsForSummary: financialsForSummary ?? this.financialsForSummary,
    );
  }
}

class TransactionError extends TransactionState {
  final String? errorMessage;
  const TransactionError({
    super.allTransactions,
    super.selectedMonth,
    super.availableMonths,
    super.currentListFilterType,
    super.financialsForSummary,
    required this.errorMessage,
  });
  
  @override
  List<Object?> get props => [
    allTransactions,
    selectedMonth,
    availableMonths,
    currentListFilterType,
    financialsForSummary,
    errorMessage,
  ];

  @override
  TransactionError copyWith({
    List<TransactionModel>? allTransactions,
    String? selectedMonth,
    List<String>? availableMonths,
    MoneyType? currentListFilterType,
    Map<String, int>? financialsForSummary,
    String? errorMessage,
  }) {
    return TransactionError(
      allTransactions: allTransactions ?? this.allTransactions,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      availableMonths: availableMonths ?? this.availableMonths,
      currentListFilterType: currentListFilterType ?? this.currentListFilterType,
      financialsForSummary: financialsForSummary ?? this.financialsForSummary,
      errorMessage: errorMessage ?? this.errorMessage!,
    );
  }
}