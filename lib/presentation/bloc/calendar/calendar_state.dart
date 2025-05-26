import 'package:equatable/equatable.dart';
import 'package:finance_management/presentation/shared_data.dart';

abstract class CalendarState extends Equatable {
  final DateTime selectedDate;
  final DateTime currentMonth;
  final ChartTypeCalendar selectedChartType;
  final bool showAllMonth;
  final List<ChartSampleData> chartData;
  final List<TransactionModel>? allTransactions;
  final String? errorMessage;

  const CalendarState({
    required this.selectedDate,
    required this.currentMonth,
    required this.selectedChartType,
    required this.showAllMonth,
    required this.chartData,
    this.allTransactions,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    selectedDate,
    currentMonth,
    selectedChartType,
    showAllMonth,
    chartData,
    allTransactions,
    errorMessage,
  ];
}

class CalendarInitial extends CalendarState {
  const CalendarInitial({
    required super.selectedDate,
    required super.currentMonth,
    required super.selectedChartType,
    required super.showAllMonth,
    required super.chartData,
    super.allTransactions,
  });
}

class CalendarLoading extends CalendarState {
  const CalendarLoading({
    required super.selectedDate,
    required super.currentMonth,
    required super.selectedChartType,
    required super.showAllMonth,
    required super.chartData,
    super.allTransactions,
  });

  CalendarLoading.fromState({required CalendarState state})
      : super(
    selectedDate: state.selectedDate,
    currentMonth: state.currentMonth,
    selectedChartType: state.selectedChartType,
    showAllMonth: state.showAllMonth,
    chartData: state.chartData,
    allTransactions: state.allTransactions,
  );
}

class CalendarSuccess extends CalendarState {
  const CalendarSuccess({
    required super.selectedDate,
    required super.currentMonth,
    required super.selectedChartType,
    required super.showAllMonth,
    required super.chartData,
    super.allTransactions,
  });
}

class CalendarError extends CalendarState {
  const CalendarError({
    required super.selectedDate,
    required super.currentMonth,
    required super.selectedChartType,
    required super.showAllMonth,
    required super.chartData,
    super.allTransactions,
    required String super.errorMessage,
  });
}