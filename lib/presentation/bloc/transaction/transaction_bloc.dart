import 'dart:async';

import 'package:collection/collection.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;

  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  TransactionBloc(this._transactionRepository)
      : super(   const TransactionInitial(
    allTransactions: [],
    financialsForSummary: {
      'totalBalance': 0,
      'income': 0,
      'expense': 0,
      'save': 0,
    },
    selectedMonth: '',
    availableMonths: [],
    currentListFilterType: null,
  ),
  ) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<SelectMonthEvent>(_onSelectMonthEvent);
    on<SelectFilterTypeEvent>(_onSelectFilterTypeEvent);
    on<AddTransactionEvent>(_onAddTransaction);
    on<FilterTransactionsByTimeframeEvent>(_onFilterTransactionsByTimeframe);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<EditTransactionEvent>(_onEditTransaction);
  }
  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading.fromState(state: state));

    try {
      await _transactionRepository.deleteTransaction(event.transactionId);
      final updatedTransactions = List<TransactionModel>.from(state.allTransactions)
        ..removeWhere((transaction) => transaction.id == event.transactionId);

      // Recalculate financials and potentially availableMonths
      final financials = _calculateCumulativeFinancials(
        updatedTransactions,
        state.selectedMonth,
      );

      // OPTIONAL: Recalculate availableMonths if a month might become empty.
      // This adds complexity and might not be immediately necessary.
      // For now, we'll keep the existing availableMonths. A full reload would refresh it.
      // final currentMonths = updatedTransactions.map((t) => DateTime(t.time.year, t.time.month)).toSet().toList()..sort((a, b) => b.compareTo(a));
      // final newAvailableMonths = ['All'] + currentMonths.map((date) => getMonthName(date.month, date.year)).toList();
      // String newSelectedMonth = state.selectedMonth;
      // if (!newAvailableMonths.contains(newSelectedMonth)) {
      //   newSelectedMonth = newAvailableMonths.isNotEmpty ? newAvailableMonths.first : 'All';
      // }
      // final financials = _calculateCumulativeFinancials(updatedTransactions, newSelectedMonth);


      emit(
        TransactionSuccess(
          allTransactions: updatedTransactions,
          selectedMonth: state.selectedMonth, // Or newSelectedMonth if recalculating
          availableMonths: state.availableMonths, // Or newAvailableMonths
          currentListFilterType: state.currentListFilterType,
          financialsForSummary: financials,
        ),
      );
    } catch (e, stackTrace) {
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = 'Request timed out while deleting: ${e.message}';
      } else {
        errorMessage = 'Failed to delete transaction: ${e.toString()}';
      }
      debugPrint('Stack trace: $stackTrace');
      emit(
        TransactionError(
          allTransactions: state.allTransactions,
          selectedMonth: state.selectedMonth,
          availableMonths: state.availableMonths,
          currentListFilterType: state.currentListFilterType,
          financialsForSummary: state.financialsForSummary,
          errorMessage: errorMessage,
        ),
      );
    }
  }
  String getMonthName(int month, int year) {
    return '${monthNames[month - 1]} $year';
  }
  List<TransactionModel> getTransactionsForDisplay(
      List<TransactionModel> allTransactions,
      String selectedMonth,
      MoneyType? filterType,
      ) {
    List<TransactionModel> monthlyFiltered = [];

    if (selectedMonth == 'All') {
      monthlyFiltered = allTransactions;
    } else {
      final parts = selectedMonth.split(' ');
      final monthName = parts[0];
      final year = int.tryParse(parts[1]);
      final selectedMonthIndex = monthNames.indexOf(monthName) + 1;

      monthlyFiltered = allTransactions
          .where(
            (t) => t.time.month == selectedMonthIndex && t.time.year == year,
      )
          .toList();
    }

    if (filterType != null) {
      return monthlyFiltered
          .where((t) => t.idCategory.moneyType == filterType)
          .toList();
    } else {
      return monthlyFiltered;
    }
  }
  // List<TransactionModel> getTransactionsForDisplay(
  //   List<TransactionModel> allTransactions,
  //   String selectedMonth,
  //   MoneyType? filterType,
  // ) {
  //   List<TransactionModel> monthlyFiltered = [];
  //
  //   if (selectedMonth == 'All') {
  //     monthlyFiltered = allTransactions;
  //   } else {
  //     final parts = selectedMonth.split(' ');
  //     final monthName = parts[0];
  //     final year = int.tryParse(parts[1]);
  //     final selectedMonthIndex = monthNames.indexOf(monthName) + 1;
  //
  //     monthlyFiltered =
  //         allTransactions
  //             .where(
  //               (t) =>
  //                   t.time.month == selectedMonthIndex && t.time.year == year,
  //             )
  //             .toList();
  //   }
  //
  //   if (filterType != null) {
  //     return monthlyFiltered
  //         .where((t) => t.idCategory.moneyType == filterType)
  //         .toList();
  //   } else {
  //     return monthlyFiltered
  //         .where((t) => t.idCategory.moneyType != MoneyType.save)
  //         .toList();
  //   }
  // }

  Map<String, int> _calculateCumulativeFinancials(
      List<TransactionModel> allTransactions,
      String selectedMonth,
      ) {
    int cumulativeBalance = 0;
    int monthlyIncome = 0;
    int monthlyExpense = 0;
    int monthlySave = 0;
    int monthlyNetBalance = 0;

    List<TransactionModel> sortedTransactions = List.from(allTransactions)
      ..sort((a, b) => a.time.compareTo(b.time));

    int targetMonth = -1;
    int targetYear = -1;
    if (selectedMonth != 'All') {
      final parts = selectedMonth.split(' ');
      final monthName = parts[0];
      final year = int.tryParse(parts[1]);
      if (year != null) {
        targetMonth = monthNames.indexOf(monthName) + 1;
        targetYear = year;
      } else {
        debugPrint(
          'Warning: Could not parse year from selectedMonth: $selectedMonth',
        );
        targetMonth = -1;
        targetYear = -1;
      }
    }

    for (final t in sortedTransactions) {
      bool includeInCumulative = false;
      if (selectedMonth == 'All') {
        includeInCumulative = true;
      } else if (targetMonth != -1 && targetYear != -1) {
        if (t.time.year < targetYear ||
            (t.time.year == targetYear && t.time.month <= targetMonth)) {
          includeInCumulative = true;
        }
      }

      if (includeInCumulative) {
        if (t.idCategory.moneyType == MoneyType.income) {
          cumulativeBalance += t.amount;
        } else if (t.idCategory.moneyType == MoneyType.expense) {
          cumulativeBalance -= t.amount;
        } else if (t.idCategory.moneyType == MoneyType.save) {
          cumulativeBalance -= t.amount;
        }
      }

      if (selectedMonth == 'All') {
        if (t.idCategory.moneyType == MoneyType.income) {
          monthlyIncome += t.amount;
          monthlyNetBalance += t.amount;
        } else if (t.idCategory.moneyType == MoneyType.expense) {
          monthlyExpense += t.amount;
          monthlyNetBalance -= t.amount;
        } else if (t.idCategory.moneyType == MoneyType.save) {
          monthlySave += t.amount;
          monthlyNetBalance -= t.amount;
        }
      } else if (t.time.month == targetMonth && t.time.year == targetYear) {
        if (t.idCategory.moneyType == MoneyType.income) {
          monthlyIncome += t.amount;
          monthlyNetBalance += t.amount;
        } else if (t.idCategory.moneyType == MoneyType.expense) {
          monthlyExpense += t.amount;
          monthlyNetBalance -= t.amount;
        } else if (t.idCategory.moneyType == MoneyType.save) {
          monthlySave += t.amount;
          monthlyNetBalance -= t.amount;
        }
      }
    }

    return {
      'totalBalance': cumulativeBalance,
      'income': monthlyIncome,
      'expense': monthlyExpense,
      'save': monthlySave,
      'monthlyNetBalance': monthlyNetBalance,
    };
  }
  Future<void> _onLoadTransactions(
      LoadTransactionsEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionInitial(
      allTransactions: [],
      selectedMonth: 'All',
      availableMonths: ['All'],
      currentListFilterType: null,
      financialsForSummary: {
        'totalBalance': 0,
        'income': 0,
        'expense': 0,
        'save': 0,
      },
    ));
    emit(TransactionLoading.fromState(state: state));
    try {
      //await Future.delayed(const Duration(seconds: 2));
      final updatedTransactions =
      await _transactionRepository.getTransactionsAPI();

      final months =
      updatedTransactions
          .map((t) => DateTime(t.time.year, t.time.month))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      final availableMonths = ['All'] + months.map((date) => getMonthName(date.month, date.year)).toList();

      String initialSelectedMonth = event.month ?? 'All'; // Use event.month if provided, otherwise 'All'
      if (!availableMonths.contains(initialSelectedMonth)) {
        initialSelectedMonth = availableMonths.isNotEmpty ? availableMonths.first : 'All';
      }

      final initialFinancials = _calculateCumulativeFinancials(
          updatedTransactions, initialSelectedMonth
      );

      emit(
        TransactionSuccess(
          allTransactions: updatedTransactions,
          selectedMonth: initialSelectedMonth,
          availableMonths: availableMonths,
          currentListFilterType: null,
          financialsForSummary: initialFinancials,
        ),
      );
    } catch (e, stackTrace) {
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = 'Request timed out: ${e.message}';
      } else {
        errorMessage = 'Unknown error: ${e.toString()}';
      }
      debugPrint('Stack trace: $stackTrace');
      emit(
        TransactionError(
          allTransactions: state.allTransactions,
          selectedMonth: state.selectedMonth,
          availableMonths: state.availableMonths,
          currentListFilterType: state.currentListFilterType,
          financialsForSummary: state.financialsForSummary,
          errorMessage: errorMessage,
        ),
      );
    }
  }
  // Future<void> _onLoadTransactions(
  //   LoadTransactionsEvent event,
  //   Emitter<TransactionState> emit,
  // ) async {
  //   emit(TransactionLoading.fromState(state: state));
  //   try {
  //     final updatedTransactions =
  //         await _transactionRepository.getTransactionsAPI();
  //
  //     final months =
  //         updatedTransactions
  //             .map((t) => DateTime(t.time.year, t.time.month))
  //             .toSet()
  //             .toList()
  //           ..sort((a, b) => b.compareTo(a));
  //     final availableMonths =
  //         ['All'] +
  //         months.map((date) => getMonthName(date.month, date.year)).toList();
  //
  //     // String initialSelectedMonth = getMonthName(
  //     //   DateTime.now().month,
  //     //   DateTime.now().year,
  //     // );
  //     String initialSelectedMonth = 'All';
  //     if (!availableMonths.contains(initialSelectedMonth)) {
  //       initialSelectedMonth =
  //           availableMonths.isNotEmpty ? availableMonths.first : 'All';
  //     }
  //
  //     final initialFinancials = _calculateCumulativeFinancials(
  //       updatedTransactions,
  //       initialSelectedMonth,
  //     );
  //
  //     emit(
  //       TransactionSuccess(
  //         allTransactions: updatedTransactions,
  //         selectedMonth: initialSelectedMonth,
  //         availableMonths: availableMonths,
  //         currentListFilterType: null,
  //         financialsForSummary: initialFinancials,
  //       ),
  //     );
  //   } catch (e, stackTrace) {
  //     String errorMessage;
  //     if (e is TimeoutException) {
  //       errorMessage = 'Request timed out: ${e.message}';
  //     } else {
  //       errorMessage = 'Unknown error: ${e.toString()}';
  //     }
  //     debugPrint('Stack trace: $stackTrace');
  //     emit(
  //       TransactionError(
  //         allTransactions: state.allTransactions,
  //         selectedMonth: state.selectedMonth,
  //         availableMonths: state.availableMonths,
  //         currentListFilterType: state.currentListFilterType,
  //         financialsForSummary: state.financialsForSummary,
  //         errorMessage: errorMessage,
  //       ),
  //     );
  //   }
  //
  //
  // }
  Future<void> _onEditTransaction(
      EditTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading.fromState(state: state));
    try {
      await _transactionRepository.updateTransaction(
        event.updatedTransaction,
      );
      final updatedTransactions = state.allTransactions.map((transaction) {
        if (transaction.id == event.updatedTransaction.id) {
          return event.updatedTransaction;
        }
        return transaction;
      }).toList();
      final financials = _calculateCumulativeFinancials(
        updatedTransactions,
        state.selectedMonth,
      );
      emit(
        TransactionSuccess(
          allTransactions: updatedTransactions,
          selectedMonth: state.selectedMonth,
          availableMonths: state.availableMonths,
          currentListFilterType: state.currentListFilterType,
          financialsForSummary: financials,
        ),
      );
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to edit transaction: ${e.toString()}';
      debugPrint('Stack trace: $stackTrace');
      emit(
        TransactionError(
          allTransactions: state.allTransactions,
          selectedMonth: state.selectedMonth,
          availableMonths: state.availableMonths,
          currentListFilterType: state.currentListFilterType,
          financialsForSummary: state.financialsForSummary,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  void _onSelectMonthEvent(
      SelectMonthEvent event,
      Emitter<TransactionState> emit,
      ) {
    final financials = _calculateCumulativeFinancials(
      state.allTransactions,
      event.selectedMonth,
    );

    emit(
      TransactionSuccess(
        allTransactions: state.allTransactions,
        selectedMonth: event.selectedMonth,
        availableMonths: state.availableMonths,
        currentListFilterType: state.currentListFilterType,
        financialsForSummary: financials,
      ),
    );
  }

  void _onSelectFilterTypeEvent(
      SelectFilterTypeEvent event,
      Emitter<TransactionState> emit,
      ) {
    emit(
      TransactionSuccess(
        allTransactions: state.allTransactions,
        selectedMonth: state.selectedMonth,
        availableMonths: state.availableMonths,
        currentListFilterType: event.filterType,
        financialsForSummary: state.financialsForSummary,
      ),
    );
  }

  int calculateTotalBalance(List<TransactionModel> transactions) {
    int balance = 0;
    for (final transaction in transactions) {
      if (transaction.idCategory.moneyType == MoneyType.income) {
        balance += transaction.amount;
      } else if (transaction.idCategory.moneyType == MoneyType.expense ||
          transaction.idCategory.moneyType == MoneyType.save) {
        balance -= transaction.amount;
      }
    }
    return balance;
  }

  Map<String, int> calculateFinancialsForMoneyType(
      List<TransactionModel> allTransactions,
      MoneyType type,
      ) {
    int totalAmount = 0;
    int netChange = 0;

    final transactionsOfType =
    allTransactions.where((t) => t.idCategory.moneyType == type).toList();

    for (final t in transactionsOfType) {
      totalAmount += t.amount;
      if (t.idCategory.moneyType == MoneyType.income) {
        netChange += t.amount;
      } else if (t.idCategory.moneyType == MoneyType.expense) {
        netChange -= t.amount;
      } else if (t.idCategory.moneyType == MoneyType.save) {
        netChange -= t.amount;
      }
    }

    return {'totalAmount': totalAmount, 'netChange': netChange};
  }

  Future<void> _onAddTransaction(
      AddTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading.fromState(state: state));
    try {
      final existingTransaction = state.allTransactions
          .firstWhereOrNull((t) => t.id == event.newTransaction.id);
      if (existingTransaction != null) {
        debugPrint('Duplicate transaction with ID ${event.newTransaction.id} ignored.');
        return; // Skip adding the duplicate
      }
      await _transactionRepository.addTransaction(event.newTransaction);
      final updatedTransactions = await _transactionRepository.getTransactionsAPI();
      final financials = _calculateCumulativeFinancials(
        updatedTransactions,
        state.selectedMonth,
      );
      emit(
        TransactionSuccess(
          allTransactions: updatedTransactions,
          selectedMonth: state.selectedMonth,
          availableMonths: state.availableMonths,
          currentListFilterType: state.currentListFilterType,
          financialsForSummary: financials,
        ),
      );
    } catch (e, stackTrace) {
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = 'Request timed out: ${e.message}';
      } else {
        errorMessage = 'Failed to add transaction: ${e.toString()}';
      }
      debugPrint('Stack trace: $stackTrace');
      emit(
        TransactionError(
          allTransactions: state.allTransactions,
          selectedMonth: state.selectedMonth,
          availableMonths: state.availableMonths,
          currentListFilterType: state.currentListFilterType,
          financialsForSummary: state.financialsForSummary,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  void _onFilterTransactionsByTimeframe(
      FilterTransactionsByTimeframeEvent event,
      Emitter<TransactionState> emit,
      ) {
    emit(
      TransactionSuccess(
        allTransactions: state.allTransactions,
        selectedMonth: state.selectedMonth,
        availableMonths: state.availableMonths,
        currentListFilterType: _mapFilterTypeToListFilterType(event.filterType),
        financialsForSummary: state.financialsForSummary,
      ),
    );
  }

  MoneyType? _mapFilterTypeToListFilterType(ListTransactionFilter filterType) {
    switch (filterType) {
      case ListTransactionFilter.daily:
        return null;
      case ListTransactionFilter.weekly:
        return null;
      case ListTransactionFilter.monthly:
        return null;
      case ListTransactionFilter.all:
        return null;
    }
  }

  int getFoodLastWeek() {
    final now = DateTime.now();

    DateTime startOfCurrentWeek = now.subtract(Duration(days: now.weekday - 1));

    DateTime startOfLastWeek = startOfCurrentWeek.subtract(
      const Duration(days: 7),
    );

    DateTime endOfLastWeek = startOfCurrentWeek.subtract(
      const Duration(days: 1),
    );

    int foodExpense = 0;
    for (var transaction in state.allTransactions) {
      if (transaction.time.isAfter(
        startOfLastWeek.subtract(const Duration(microseconds: 1)),
      ) &&
          transaction.time.isBefore(
            endOfLastWeek.add(const Duration(days: 1)),
          )) {
        if (transaction.idCategory.moneyType == MoneyType.expense &&
            transaction.idCategory.categoryType == "Food") {
          foodExpense += transaction.amount;
        }
      }
    }
    return foodExpense;
  }

  int getRevenueLastWeek() {
    final now = DateTime.now();

    DateTime startOfCurrentWeek = now.subtract(Duration(days: now.weekday - 1));

    DateTime startOfLastWeek = startOfCurrentWeek.subtract(
      const Duration(days: 7),
    );

    DateTime endOfLastWeek = startOfCurrentWeek.subtract(
      const Duration(days: 1),
    );

    int revenue = 0;
    for (var transaction in state.allTransactions) {
      if (transaction.time.isAfter(
        startOfLastWeek.subtract(const Duration(microseconds: 1)),
      ) &&
          transaction.time.isBefore(
            endOfLastWeek.add(const Duration(days: 1)),
          )) {
        if (transaction.idCategory.moneyType == MoneyType.income) {
          revenue += transaction.amount;
        }
      }
    }
    return revenue;
  }

  int getCurrentMonthExpense() {
    final now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    int expense = 0;
    for (var transaction in state.allTransactions) {
      if (transaction.time.month == currentMonth &&
          transaction.time.year == currentYear &&
          transaction.idCategory.moneyType == MoneyType.expense) {
        expense += transaction.amount;
      }
    }
    return expense;
  }
  Future<TransactionModel?> getTransactionById(int id) async {
    return state.allTransactions.firstWhereOrNull((transaction) => transaction.id == id);
  }

}