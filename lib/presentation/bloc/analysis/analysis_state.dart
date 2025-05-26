import 'package:equatable/equatable.dart';
import 'package:finance_management/presentation/shared_data.dart';

abstract class AnalysisState extends Equatable {
  final List<TransactionModel>? allTransactions;
  final List<BaseAnalysis>? currentChartData;
  final TimeFilterAnalysis? selectedTimeFilter;
  final DateTime? currentDate;
  final String? errorMessage;

  const AnalysisState({
    this.allTransactions,
    this.currentChartData,
    this.selectedTimeFilter,
    this.currentDate,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    allTransactions,
    currentChartData,
    selectedTimeFilter,
    currentDate,
    errorMessage,
  ];
}

class AnalysisInitial extends AnalysisState {
  const AnalysisInitial({
    super.allTransactions,
    super.currentChartData,
    super.selectedTimeFilter = TimeFilterAnalysis.daily,
    super.currentDate,
  });
}

class AnalysisLoading extends AnalysisState {
  const AnalysisLoading({
    super.allTransactions,
    super.currentChartData,
    super.selectedTimeFilter,
    super.currentDate,
  });

  AnalysisLoading.fromState({required AnalysisState state})
      : super(
    allTransactions: state.allTransactions,
    currentChartData: state.currentChartData,
    selectedTimeFilter: state.selectedTimeFilter,
    currentDate: state.currentDate,
  );
}

class AnalysisSuccess extends AnalysisState {
  const AnalysisSuccess({
    super.allTransactions,
    super.currentChartData,
    super.selectedTimeFilter,
    super.currentDate,
  });
}

class AnalysisError extends AnalysisState {
  const AnalysisError({
    super.allTransactions,
    super.currentChartData,
    super.selectedTimeFilter,
    super.currentDate,
    required String super.errorMessage,
  });
}