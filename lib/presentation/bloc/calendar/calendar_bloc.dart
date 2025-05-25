import 'package:finance_management/presentation/bloc/calendar/calendar_event.dart';
import 'package:finance_management/presentation/bloc/calendar/calendar_state.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  static const int maxCategories = 5;
  final TransactionRepository _transactionRepository;

  CalendarBloc(this._transactionRepository)
      : super(
    CalendarInitial(
      selectedDate: DateTime.now(),
      currentMonth: DateTime.now(),
      selectedChartType: ChartType.spends,
      showAllMonth: true,
      chartData: [],
      allTransactions: [],
    ),
  ) {
    on<LoadCalendarTransactionsEvent>(_onLoadTransactions);
    on<SelectDateEvent>(_onSelectDate);
    on<ToggleAllMonthEvent>(_onToggleAllMonth);
    on<ChangeMonthEvent>(_onChangeMonth);
    on<ChangeYearEvent>(_onChangeYear);
    on<ChangeChartTypeEvent>(_onChangeChartType);
  }

  Future<void> _onLoadTransactions(
      LoadCalendarTransactionsEvent event,
      Emitter<CalendarState> emit,
      ) async {
    emit(CalendarLoading.fromState(state: state));
    try {
      final transactions = await _transactionRepository.getTransactionsAPI();
      emit(
        CalendarSuccess(
          selectedDate: state.selectedDate,
          currentMonth: state.currentMonth,
          selectedChartType: state.selectedChartType,
          showAllMonth: state.showAllMonth,
          chartData: _generateChartData(state, transactions),
          allTransactions: transactions,
        ),
      );
    } catch (e, stackTrace) {
      String errorMessage = e is Exception ? e.toString() : 'Unknown error';
      print('Stack trace: $stackTrace');
      emit(
        CalendarError(
          selectedDate: state.selectedDate,
          currentMonth: state.currentMonth,
          selectedChartType: state.selectedChartType,
          showAllMonth: state.showAllMonth,
          chartData: state.chartData,
          allTransactions: state.allTransactions,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  void _onSelectDate(SelectDateEvent event, Emitter<CalendarState> emit) {
    final newState = CalendarSuccess(
      selectedDate: DateTime(state.currentMonth.year, state.currentMonth.month, event.day),
      currentMonth: state.currentMonth,
      selectedChartType: state.selectedChartType,
      showAllMonth: false,
      chartData: _generateChartData(state, state.allTransactions ?? []),
      allTransactions: state.allTransactions,
    );
    emit(newState);
  }

  void _onToggleAllMonth(ToggleAllMonthEvent event, Emitter<CalendarState> emit) {
    final newState = CalendarSuccess(
      selectedDate: state.selectedDate,
      currentMonth: state.currentMonth,
      selectedChartType: state.selectedChartType,
      showAllMonth: true,
      chartData: _generateChartData(state, state.allTransactions ?? []),
      allTransactions: state.allTransactions,
    );
    emit(newState);
  }

  void _onChangeMonth(ChangeMonthEvent event, Emitter<CalendarState> emit) {
    final newState = CalendarSuccess(
      selectedDate: state.selectedDate,
      currentMonth: DateTime(state.currentMonth.year, event.month),
      selectedChartType: state.selectedChartType,
      showAllMonth: true,
      chartData: _generateChartData(state, state.allTransactions ?? []),
      allTransactions: state.allTransactions,
    );
    emit(newState);
  }

  void _onChangeYear(ChangeYearEvent event, Emitter<CalendarState> emit) {
    final newState = CalendarSuccess(
      selectedDate: state.selectedDate,
      currentMonth: DateTime(event.year, state.currentMonth.month),
      selectedChartType: state.selectedChartType,
      showAllMonth: true,
      chartData: _generateChartData(state, state.allTransactions ?? []),
      allTransactions: state.allTransactions,
    );
    emit(newState);
  }

  void _onChangeChartType(ChangeChartTypeEvent event, Emitter<CalendarState> emit) {
    final newState = CalendarSuccess(
      selectedDate: state.selectedDate,
      currentMonth: state.currentMonth,
      selectedChartType: event.chartType,
      showAllMonth: state.showAllMonth,
      chartData: _generateChartData(state, state.allTransactions ?? [], chartType: event.chartType),
      allTransactions: state.allTransactions,
    );
    emit(newState);
  }

  List<ChartSampleData> _generateChartData(
      CalendarState state,
      List<TransactionModel> transactions, {
        ChartType? chartType,
      }) {
    final selectedChartType = chartType ?? state.selectedChartType;
    final filteredTransactions = _getFilteredTransactions(state, transactions);

    if (selectedChartType == ChartType.spends) {
      return _generateSpendsData(filteredTransactions);
    } else {
      return _generateCategoriesData(filteredTransactions);
    }
  }

  List<TransactionModel> _getFilteredTransactions(
      CalendarState state,
      List<TransactionModel> transactions,
      ) {
    if (state.showAllMonth) {
      return transactions.where((transaction) {
        return transaction.time.year == state.currentMonth.year &&
            transaction.time.month == state.currentMonth.month;
      }).toList();
    } else {
      return transactions.where((transaction) {
        return transaction.time.year == state.selectedDate.year &&
            transaction.time.month == state.selectedDate.month &&
            transaction.time.day == state.selectedDate.day;
      }).toList();
    }
  }

  List<ChartSampleData> _generateSpendsData(List<TransactionModel> transactions) {
    final expenseTransactions = transactions
        .where((t) => t.idCategory.moneyType == MoneyType.expense)
        .toList();
    final categoryTotals = _calculateCategoryTotals(expenseTransactions);
    final totalExpenses =
    categoryTotals.values.fold(0.0, (sum, value) => sum + value);
    return _createOptimizedChartData(categoryTotals, totalExpenses, _getExpenseColors());
  }

  List<ChartSampleData> _generateCategoriesData(List<TransactionModel> transactions) {
    final categoryTotals = _calculateCategoryTotals(transactions);
    final totalAmount = categoryTotals.values.fold(0.0, (sum, value) => sum + value);
    return _createOptimizedChartData(categoryTotals, totalAmount, _getCategoryColors());
  }

  Map<String, double> _calculateCategoryTotals(List<TransactionModel> transactions) {
    final Map<String, double> categoryTotals = {};
    for (var transaction in transactions) {
      final categoryName = transaction.idCategory.categoryType;
      categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + transaction.amount;
    }
    return categoryTotals;
  }

  List<ChartSampleData> _createOptimizedChartData(
      Map<String, double> categoryTotals,
      double total,
      List<Color> colors,
      ) {
    if (categoryTotals.isEmpty) {
      return [
        ChartSampleData(x: 'No Data', y: 100, color: AppColors.lightBlue),
      ];
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final chartData = <ChartSampleData>[];
    int colorIndex = 0;

    for (int i = 0; i < sortedEntries.length && i < maxCategories - 1; i++) {
      final entry = sortedEntries[i];
      double percentage = total > 0 ? (entry.value / total) * 100 : 0;

      if (percentage > 2.0) {
        chartData.add(
          ChartSampleData(
            x: entry.key,
            y: percentage,
            color: colors[colorIndex % colors.length],
          ),
        );
        colorIndex++;
      }
    }

    if (sortedEntries.length > maxCategories - 1) {
      double othersTotal = 0;
      for (int i = maxCategories - 1; i < sortedEntries.length; i++) {
        othersTotal += sortedEntries[i].value;
      }

      for (int i = 0; i < sortedEntries.length && i < maxCategories - 1; i++) {
        final entry = sortedEntries[i];
        double percentage = total > 0 ? (entry.value / total) * 100 : 0;
        if (percentage <= 2.0) {
          othersTotal += entry.value;
        }
      }

      if (othersTotal > 0) {
        double othersPercentage = total > 0 ? (othersTotal / total) * 100 : 0;
        chartData.add(
          ChartSampleData(
            x: 'Others',
            y: othersPercentage,
            color: colors[colorIndex % colors.length],
          ),
        );
      }
    }

    return chartData.isEmpty
        ? [ChartSampleData(x: 'No Data', y: 100, color: AppColors.lightBlue)]
        : chartData;
  }

  List<Color> _getExpenseColors() {
    return [
      AppColors.oceanBlue,
      AppColors.vividBlue,
      AppColors.lightBlue,
      AppColors.caribbeanGreen,
      AppColors.lightGreen,
      AppColors.fenceGreen,
    ];
  }

  List<Color> _getCategoryColors() {
    return [
      AppColors.caribbeanGreen,
      AppColors.lightGreen,
      AppColors.fenceGreen,
      AppColors.oceanBlue,
      AppColors.vividBlue,
      AppColors.lightBlue,
    ];
  }
}