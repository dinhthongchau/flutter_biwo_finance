import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_management/presentation/shared_data.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final TransactionRepository _transactionRepository;

  AnalysisBloc(this._transactionRepository) : super(AnalysisInitial(
    allTransactions: const [],
    currentChartData: const [],
    selectedTimeFilter: TimeFilterAnalysis.daily,
    currentDate: DateTime.now(),
    startDate: DateTime.now().subtract(const Duration(days: 7)),
    endDate: DateTime.now(),
  )) {
    on<LoadAnalysisDataEvent>(_onLoadAnalysisData);
    on<ChangeTimeFilterEvent>(_onChangeTimeFilter);
    on<ChangeDateRangeEvent>(_onChangeDateRange);
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
      
      // Calculate default date range based on filter
      DateTime startDate;
      DateTime endDate;
      
      if (timeFilter == TimeFilterAnalysis.daily) {
        // For daily view, start from Monday of current week
        final currentWeekday = currentDate.weekday;
        startDate = currentDate.subtract(Duration(days: currentWeekday - 1));
        endDate = currentDate;
      } else if (timeFilter == TimeFilterAnalysis.weekly) {
        // For weekly view, set date range to current month
        final currentMonth = DateTime(currentDate.year, currentDate.month, 1);
        final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
        startDate = currentMonth;
        endDate = lastDayOfMonth;
      } else {
        startDate = state.startDate ?? currentDate.subtract(const Duration(days: 7));
        endDate = state.endDate ?? currentDate;
      }
      
      final chartData = _generateChartData(
        transactions, 
        timeFilter, 
        currentDate,
        startDate,
        endDate,
      );

      emit(AnalysisSuccess(
        allTransactions: transactions,
        currentChartData: chartData,
        selectedTimeFilter: timeFilter,
        currentDate: currentDate,
        startDate: startDate,
        endDate: endDate,
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
        startDate: state.startDate,
        endDate: state.endDate,
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
        startDate: state.startDate,
        endDate: state.endDate,
        errorMessage: 'No transactions available to filter',
      ));
      return;
    }

    emit(AnalysisLoading.fromState(state: state));

    try {
      final currentDate = state.currentDate ?? DateTime.now();
      
      // Reset date range when changing filter
      DateTime startDate;
      DateTime endDate;
      
      if (event.timeFilter == TimeFilterAnalysis.daily) {
        // For daily view, start from Monday of current week
        final currentWeekday = currentDate.weekday;
        startDate = currentDate.subtract(Duration(days: currentWeekday - 1));
        endDate = currentDate;
      } else if (event.timeFilter == TimeFilterAnalysis.weekly) {
        // For weekly view, set date range to current month
        final currentMonth = DateTime(currentDate.year, currentDate.month, 1);
        final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
        startDate = currentMonth;
        endDate = lastDayOfMonth;
      } else {
        startDate = state.startDate ?? currentDate.subtract(const Duration(days: 7));
        endDate = state.endDate ?? currentDate;
      }
      
      final chartData = _generateChartData(
        state.allTransactions!,
        event.timeFilter,
        currentDate,
        startDate,
        endDate,
      );

      emit(AnalysisSuccess(
        allTransactions: state.allTransactions,
        currentChartData: chartData,
        selectedTimeFilter: event.timeFilter,
        currentDate: currentDate,
        startDate: startDate,
        endDate: endDate,
      ));
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to filter data: ${e.toString()}';
      customPrint('Stack trace: $stackTrace');
      emit(AnalysisError(
        allTransactions: state.allTransactions,
        currentChartData: state.currentChartData,
        selectedTimeFilter: event.timeFilter,
        currentDate: state.currentDate,
        startDate: state.startDate,
        endDate: state.endDate,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onChangeDateRange(
      ChangeDateRangeEvent event,
      Emitter<AnalysisState> emit,
      ) async {
    if (state.allTransactions == null || state.allTransactions!.isEmpty) {
      emit(AnalysisError(
        allTransactions: state.allTransactions,
        currentChartData: state.currentChartData,
        selectedTimeFilter: state.selectedTimeFilter,
        currentDate: state.currentDate,
        startDate: event.startDate,
        endDate: event.endDate,
        errorMessage: 'No transactions available to filter',
      ));
      return;
    }

    emit(AnalysisLoading.fromState(state: state));

    try {
      final chartData = _generateChartData(
        state.allTransactions!,
        state.selectedTimeFilter ?? TimeFilterAnalysis.daily,
        state.currentDate ?? DateTime.now(),
        event.startDate,
        event.endDate,
      );

      emit(AnalysisSuccess(
        allTransactions: state.allTransactions,
        currentChartData: chartData,
        selectedTimeFilter: state.selectedTimeFilter,
        currentDate: state.currentDate,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to change date range: ${e.toString()}';
      customPrint('Stack trace: $stackTrace');
      emit(AnalysisError(
        allTransactions: state.allTransactions,
        currentChartData: state.currentChartData,
        selectedTimeFilter: state.selectedTimeFilter,
        currentDate: state.currentDate,
        startDate: event.startDate,
        endDate: event.endDate,
        errorMessage: errorMessage,
      ));
    }
  }

  List<BaseAnalysis> _generateChartData(
      List<TransactionModel> transactions,
      TimeFilterAnalysis filter,
      DateTime currentDate,
      DateTime startDate,
      DateTime endDate,
      ) {
    switch (filter) {
      case TimeFilterAnalysis.daily:
        return _generateDailyData(transactions, currentDate, startDate, endDate);
      case TimeFilterAnalysis.weekly:
        return _generateWeeklyData(transactions, currentDate, startDate, endDate);
      case TimeFilterAnalysis.monthly:
        return _generateMonthlyData(transactions, currentDate);
      case TimeFilterAnalysis.year:
        return _generateYearlyData(transactions, currentDate);
    }
  }

  List<DailyAnalysis> _generateDailyData(
      List<TransactionModel> transactions,
      DateTime currentDate,
      DateTime startDate,
      DateTime endDate,
      ) {
    List<DailyAnalysis> dailyData = [];
    
    // Ensure we're starting from a Monday
    if (startDate.weekday != 1) {
      final daysToSubtract = startDate.weekday - 1;
      startDate = startDate.subtract(Duration(days: daysToSubtract));
    }
    
    // Always show 7 days (a full week)
    final int daysToShow = 7;
    
    // Generate data for each day of the week (Monday to Sunday)
    for (int i = 0; i < daysToShow; i++) {
      final targetDate = startDate.add(Duration(days: i));
      
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
      DateTime startDate,
      DateTime endDate,
      ) {
    List<WeeklyAnalysis> weeklyData = [];
    
    // Get the current month from startDate (which should be first day of month)
    final currentMonth = DateTime(startDate.year, startDate.month, 1);
    
    // Calculate the last day of the month
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    
    // Define the 4 weeks of the month
    final weeks = [
      // Week 1: 1-7
      {
        'start': DateTime(currentMonth.year, currentMonth.month, 1),
        'end': DateTime(currentMonth.year, currentMonth.month, 7, 23, 59, 59),
        'number': 1
      },
      // Week 2: 8-14
      {
        'start': DateTime(currentMonth.year, currentMonth.month, 8),
        'end': DateTime(currentMonth.year, currentMonth.month, 14, 23, 59, 59),
        'number': 2
      },
      // Week 3: 15-21
      {
        'start': DateTime(currentMonth.year, currentMonth.month, 15),
        'end': DateTime(currentMonth.year, currentMonth.month, 21, 23, 59, 59),
        'number': 3
      },
      // Week 4: 22-end of month
      {
        'start': DateTime(currentMonth.year, currentMonth.month, 22),
        'end': DateTime(currentMonth.year, currentMonth.month, lastDayOfMonth, 23, 59, 59),
        'number': 4
      },
    ];
    
    // Generate data for each week
    for (var week in weeks) {
      final weekStartDate = week['start'] as DateTime;
      final weekEndDate = week['end'] as DateTime;
      final weekNumber = week['number'] as int;
      
      // Skip weeks that don't exist in short months (e.g. February might not have full 4th week)
      if (weekStartDate.day > lastDayOfMonth) continue;
      
      final weekTransactions = transactions.where((transaction) {
        return transaction.time.isAfter(weekStartDate.subtract(const Duration(milliseconds: 1))) &&
            transaction.time.isBefore(weekEndDate.add(const Duration(milliseconds: 1)));
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
        weekNumber,
        weekStartDate,
        weekEndDate,
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