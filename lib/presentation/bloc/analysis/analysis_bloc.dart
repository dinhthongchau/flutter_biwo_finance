import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_management/presentation/shared_data.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final TransactionRepository _transactionRepository;

  AnalysisBloc(this._transactionRepository) : super(const AnalysisInitial()) {
    on<LoadAnalysisDataEvent>(_onLoadAnalysisData);
    on<ChangeTimeFilterEvent>(_onChangeTimeFilter);
  }

  Future<void> _onLoadAnalysisData(
      LoadAnalysisDataEvent event,
      Emitter<AnalysisState> emit,
      ) async {
    emit(AnalysisLoading.fromState(state: state));
    try {
      final transactions = await _transactionRepository.getTransactionsAPI();
      if (transactions.isEmpty) {
        throw Exception('No transactions found');
      }

      final timeFilter = state.selectedTimeFilter ?? TimeFilterAnalysis.daily;
      final currentDate = DateTime.now();
      final chartData = _generateChartData(transactions, timeFilter, currentDate);

      emit(AnalysisSuccess(
        allTransactions: transactions,
        currentChartData: chartData,
        selectedTimeFilter: timeFilter,
        currentDate: currentDate,
      ));
    } catch (e, stackTrace) {
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = 'Request timed out: ${e.message}';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }
      customPrint('Stack trace: $stackTrace');
      emit(AnalysisError(
        allTransactions: state.allTransactions,
        currentChartData: state.currentChartData,
        selectedTimeFilter: state.selectedTimeFilter,
        currentDate: state.currentDate,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onChangeTimeFilter(
      ChangeTimeFilterEvent event,
      Emitter<AnalysisState> emit,
      ) async {
    if (state.allTransactions == null || state.allTransactions!.isEmpty) {
      emit(AnalysisError(
        allTransactions: state.allTransactions,
        currentChartData: state.currentChartData,
        selectedTimeFilter: event.timeFilter,
        currentDate: state.currentDate,
        errorMessage: 'No transactions available to filter',
      ));
      return;
    }

    emit(AnalysisLoading.fromState(state: state));

    try {
      final chartData = _generateChartData(
        state.allTransactions!,
        event.timeFilter,
        state.currentDate ?? DateTime.now(),
      );

      emit(AnalysisSuccess(
        allTransactions: state.allTransactions,
        currentChartData: chartData,
        selectedTimeFilter: event.timeFilter,
        currentDate: state.currentDate,
      ));
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to filter data: ${e.toString()}';
      customPrint('Stack trace: $stackTrace');
      emit(AnalysisError(
        allTransactions: state.allTransactions,
        currentChartData: state.currentChartData,
        selectedTimeFilter: event.timeFilter,
        currentDate: state.currentDate,
        errorMessage: errorMessage,
      ));
    }
  }

  List<BaseAnalysis> _generateChartData(
      List<TransactionModel> transactions,
      TimeFilterAnalysis filter,
      DateTime currentDate,
      ) {
    switch (filter) {
      case TimeFilterAnalysis.daily:
        return _generateDailyData(transactions, currentDate);
      case TimeFilterAnalysis.weekly:
        return _generateWeeklyData(transactions, currentDate);
      case TimeFilterAnalysis.monthly:
        return _generateMonthlyData(transactions, currentDate);
      case TimeFilterAnalysis.year:
        return _generateYearlyData(transactions, currentDate);
    }
  }

  List<DailyAnalysis> _generateDailyData(
      List<TransactionModel> transactions,
      DateTime currentDate,
      ) {
    List<DailyAnalysis> dailyData = [];

    for (int i = 6; i >= 0; i--) {
      final targetDate = currentDate.subtract(Duration(days: i));
      final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final endOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);

      final dayTransactions = transactions.where((transaction) {
        return transaction.time.isAfter(startOfDay.subtract(const Duration(milliseconds: 1))) &&
            transaction.time.isBefore(endOfDay.add(const Duration(milliseconds: 1)));
      }).toList();

      int totalIncome = 0;
      int totalExpense = 0;

      for (var transaction in dayTransactions) {
        if (transaction.idCategory.moneyType == MoneyType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.idCategory.moneyType == MoneyType.expense) {
          totalExpense += transaction.amount;
        }
      }

      dailyData.add(DailyAnalysis(
        targetDate,
        startOfDay,
        endOfDay,
        totalIncome,
        totalExpense,
      ));
    }

    return dailyData;
  }

  List<WeeklyAnalysis> _generateWeeklyData(
      List<TransactionModel> transactions,
      DateTime currentDate,
      ) {
    List<WeeklyAnalysis> weeklyData = [];

    for (int i = 3; i >= 0; i--) {
      final startOfWeek = currentDate.subtract(Duration(days: currentDate.weekday - 1 + (i * 7)));
      final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      final weekTransactions = transactions.where((transaction) {
        return transaction.time.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) &&
            transaction.time.isBefore(endOfWeek.add(const Duration(milliseconds: 1)));
      }).toList();

      int totalIncome = 0;
      int totalExpense = 0;

      for (var transaction in weekTransactions) {
        if (transaction.idCategory.moneyType == MoneyType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.idCategory.moneyType == MoneyType.expense) {
          totalExpense += transaction.amount;
        }
      }

      weeklyData.add(WeeklyAnalysis(
        4 - i,
        startOfWeek,
        endOfWeek,
        totalIncome,
        totalExpense,
      ));
    }

    return weeklyData;
  }

  List<MonthlyAnalysis> _generateMonthlyData(
      List<TransactionModel> transactions,
      DateTime currentDate,
      ) {
    List<MonthlyAnalysis> monthlyData = [];

    for (int i = 4; i >= 0; i--) {
      final targetMonth = DateTime(currentDate.year, currentDate.month - i, 1);
      final startOfMonth = DateTime(targetMonth.year, targetMonth.month, 1);
      final endOfMonth = DateTime(targetMonth.year, targetMonth.month + 1, 1).subtract(const Duration(milliseconds: 1));

      final monthTransactions = transactions.where((transaction) {
        return transaction.time.isAfter(startOfMonth.subtract(const Duration(milliseconds: 1))) &&
            transaction.time.isBefore(endOfMonth.add(const Duration(milliseconds: 1)));
      }).toList();

      int totalIncome = 0;
      int totalExpense = 0;

      for (var transaction in monthTransactions) {
        if (transaction.idCategory.moneyType == MoneyType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.idCategory.moneyType == MoneyType.expense) {
          totalExpense += transaction.amount;
        }
      }

      monthlyData.add(MonthlyAnalysis(
        targetMonth.month,
        startOfMonth,
        endOfMonth,
        totalIncome,
        totalExpense,
      ));
    }

    return monthlyData;
  }

  List<YearAnalysis> _generateYearlyData(
      List<TransactionModel> transactions,
      DateTime currentDate,
      ) {
    List<YearAnalysis> yearlyData = [];

    for (int i = 3; i >= 0; i--) {
      final targetYear = currentDate.year - i;
      final startOfYear = DateTime(targetYear, 1, 1);
      final endOfYear = DateTime(targetYear, 12, 31, 23, 59, 59);

      final yearTransactions = transactions.where((transaction) {
        return transaction.time.isAfter(startOfYear.subtract(const Duration(milliseconds: 1))) &&
            transaction.time.isBefore(endOfYear.add(const Duration(milliseconds: 1)));
      }).toList();

      int totalIncome = 0;
      int totalExpense = 0;

      for (var transaction in yearTransactions) {
        if (transaction.idCategory.moneyType == MoneyType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.idCategory.moneyType == MoneyType.expense) {
          totalExpense += transaction.amount;
        }
      }

      yearlyData.add(YearAnalysis(
        targetYear,
        startOfYear,
        endOfYear,
        totalIncome,
        totalExpense,
      ));
    }

    return yearlyData;
  }
}