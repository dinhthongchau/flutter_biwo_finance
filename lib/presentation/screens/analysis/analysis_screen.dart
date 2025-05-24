import 'package:finance_management/presentation/screens/categories/category_detail/category_detail_save_screen.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:finance_management/presentation/widgets/build_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

abstract class BaseAnalysis {
  final int income;
  final int expense;

  BaseAnalysis(this.income, this.expense);

  String get xValue;
}

class DailyAnalysis extends BaseAnalysis {
  final DateTime day;
  final DateTime startDate;
  final DateTime endDate;

  DailyAnalysis(this.day, this.startDate, this.endDate, int income, int expense)
    : super(income, expense);

  @override
  String get xValue => DateFormat('EEE').format(day);
}

class WeeklyAnalysis extends BaseAnalysis {
  final int weekNumber;
  final DateTime startDate;
  final DateTime endDate;

  WeeklyAnalysis(
    this.weekNumber,
    this.startDate,
    this.endDate,
    int income,
    int expense,
  ) : super(income, expense);

  @override
  String get xValue => 'Week $weekNumber';
}

class MonthlyAnalysis extends BaseAnalysis {
  final int monthNumber;
  final DateTime startDate;
  final DateTime endDate;

  MonthlyAnalysis(
    this.monthNumber,
    this.startDate,
    this.endDate,
    int income,
    int expense,
  ) : super(income, expense);

  @override
  String get xValue => DateFormat('MMM').format(DateTime(2025, monthNumber));
}

class YearAnalysis extends BaseAnalysis {
  final int year;
  final DateTime startDate;
  final DateTime endDate;

  YearAnalysis(this.year, this.startDate, this.endDate, int income, int expense)
    : super(income, expense);

  @override
  String get xValue => year.toString();
}

enum TimeFilter { daily, weekly, monthly, year }

class AnalysisScreen extends StatefulWidget {
  static const String routeName = '/analysis-screen';
  final String searchScreenPath;
  final String calendarScreenPath;

  const AnalysisScreen({
    super.key,
    required this.searchScreenPath,
    required this.calendarScreenPath,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  TimeFilter _selectedTimeFilter = TimeFilter.daily;
  List<BaseAnalysis> _currentChartData = [];
  bool _isLoading = true;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    final transactionState = context.read<TransactionBloc>().state;
    _currentDate = _getDateFromSelectedMonth(transactionState.selectedMonth);
    _generateData(transactionState.allTransactions);
  }

  DateTime _getDateFromSelectedMonth(String selectedMonth) {
    if (selectedMonth.isEmpty || selectedMonth == 'All') {
      return DateTime.now();
    }

    final parts = selectedMonth.split(' ');
    final monthName = parts[0];
    final year = int.parse(parts[1]);
    final monthIndex = TransactionBloc.monthNames.indexOf(monthName) + 1;
    return DateTime(year, monthIndex);
  }

  void _generateData(List<TransactionModel> transactions) {
    setState(() {
      _isLoading = false;
      switch (_selectedTimeFilter) {
        case TimeFilter.daily:
          _currentChartData = _generateDailyData(transactions);
          break;
        case TimeFilter.weekly:
          _currentChartData = _generateWeeklyData(transactions);
          break;
        case TimeFilter.monthly:
          _currentChartData = _generateMonthlyData(transactions);
          break;
        case TimeFilter.year:
          _currentChartData = _generateYearData(transactions);
          break;
      }
    });
  }

  List<DailyAnalysis> _generateDailyData(List<TransactionModel> transactions) {
    List<DailyAnalysis> dailyData = [];

    for (int i = 6; i >= 0; i--) {
      DateTime targetDate = _currentDate.subtract(Duration(days: i));
      DateTime startOfDay = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );
      DateTime endOfDay = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        23,
        59,
        59,
      );

      List<TransactionModel> dayTransactions =
          transactions.where((transaction) {
            return transaction.time.isAfter(
                  startOfDay.subtract(const Duration(milliseconds: 1)),
                ) &&
                transaction.time.isBefore(
                  endOfDay.add(const Duration(milliseconds: 1)),
                );
          }).toList();

      int totalIncome = 0;
      int totalExpense = 0;

      for (TransactionModel transaction in dayTransactions) {
        if (transaction.idCategory.moneyType == MoneyType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.idCategory.moneyType == MoneyType.expense) {
          totalExpense += transaction.amount;
        }
      }

      dailyData.add(
        DailyAnalysis(
          targetDate,
          startOfDay,
          endOfDay,
          totalIncome,
          totalExpense,
        ),
      );
    }

    return dailyData;
  }

  List<WeeklyAnalysis> _generateWeeklyData(
    List<TransactionModel> transactions,
  ) {
    List<WeeklyAnalysis> weeklyData = [];

    for (int i = 3; i >= 0; i--) {
      DateTime startOfWeek = _currentDate.subtract(
        Duration(days: _currentDate.weekday - 1 + (i * 7)),
      );
      DateTime endOfWeek = startOfWeek.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );

      List<TransactionModel> weekTransactions =
          transactions.where((transaction) {
            return transaction.time.isAfter(
                  startOfWeek.subtract(const Duration(milliseconds: 1)),
                ) &&
                transaction.time.isBefore(
                  endOfWeek.add(const Duration(milliseconds: 1)),
                );
          }).toList();

      int totalIncome = 0;
      int totalExpense = 0;

      for (TransactionModel transaction in weekTransactions) {
        if (transaction.idCategory.moneyType == MoneyType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.idCategory.moneyType == MoneyType.expense) {
          totalExpense += transaction.amount;
        }
      }

      weeklyData.add(
        WeeklyAnalysis(
          4 - i,
          startOfWeek,
          endOfWeek,
          totalIncome,
          totalExpense,
        ),
      );
    }

    return weeklyData;
  }

  List<MonthlyAnalysis> _generateMonthlyData(
    List<TransactionModel> transactions,
  ) {
    List<MonthlyAnalysis> monthlyData = [];

    for (int i = 4; i >= 0; i--) {
      DateTime targetMonth = DateTime(
        _currentDate.year,
        _currentDate.month - i,
        1,
      );
      DateTime startOfMonth = DateTime(targetMonth.year, targetMonth.month, 1);
      DateTime endOfMonth = DateTime(
        targetMonth.year,
        targetMonth.month + 1,
        1,
      ).subtract(const Duration(milliseconds: 1));

      List<TransactionModel> monthTransactions =
          transactions.where((transaction) {
            return transaction.time.isAfter(
                  startOfMonth.subtract(const Duration(milliseconds: 1)),
                ) &&
                transaction.time.isBefore(
                  endOfMonth.add(const Duration(milliseconds: 1)),
                );
          }).toList();

      int totalIncome = 0;
      int totalExpense = 0;

      for (TransactionModel transaction in monthTransactions) {
        if (transaction.idCategory.moneyType == MoneyType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.idCategory.moneyType == MoneyType.expense) {
          totalExpense += transaction.amount;
        }
      }

      monthlyData.add(
        MonthlyAnalysis(
          targetMonth.month,
          startOfMonth,
          endOfMonth,
          totalIncome,
          totalExpense,
        ),
      );
    }

    return monthlyData;
  }

  List<YearAnalysis> _generateYearData(List<TransactionModel> transactions) {
    List<YearAnalysis> yearlyData = [];

    for (int i = 3; i >= 0; i--) {
      int targetYear = _currentDate.year - i;
      DateTime startOfYear = DateTime(targetYear, 1, 1);
      DateTime endOfYear = DateTime(targetYear, 12, 31, 23, 59, 59);

      List<TransactionModel> yearTransactions =
          transactions.where((transaction) {
            return transaction.time.isAfter(
                  startOfYear.subtract(const Duration(milliseconds: 1)),
                ) &&
                transaction.time.isBefore(
                  endOfYear.add(const Duration(milliseconds: 1)),
                );
          }).toList();

      int totalIncome = 0;
      int totalExpense = 0;

      for (TransactionModel transaction in yearTransactions) {
        if (transaction.idCategory.moneyType == MoneyType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.idCategory.moneyType == MoneyType.expense) {
          totalExpense += transaction.amount;
        }
      }

      yearlyData.add(
        YearAnalysis(
          targetYear,
          startOfYear,
          endOfYear,
          totalIncome,
          totalExpense,
        ),
      );
    }

    return yearlyData;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSuccess && state.allTransactions.isNotEmpty) {
          _currentDate = _getDateFromSelectedMonth(state.selectedMonth);
          _generateData(state.allTransactions);
        }
      },
      builder: (context, state) {
        if (_isLoading || state.allTransactions.isEmpty) {
          return Scaffold(
            appBar: buildHeader(context, "Analysis", "/home-screen/notifications-screen"),
            backgroundColor: AppColors.caribbeanGreen,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final double maxYValue =
            _currentChartData.isEmpty
                ? 1000.0
                : _currentChartData
                    .map((data) => [data.income, data.expense])
                    .expand((pair) => pair)
                    .reduce((a, b) => a > b ? a : b)
                    .toDouble();

        final double chartMaxY = (maxYValue * 1.2).ceilToDouble();

        final int totalIncome =
            _currentChartData.isEmpty
                ? 0
                : _currentChartData
                    .map((data) => data.income)
                    .reduce((a, b) => a + b);
        final int totalExpense =
            _currentChartData.isEmpty
                ? 0
                : _currentChartData
                    .map((data) => data.expense)
                    .reduce((a, b) => a + b);
        // final int totalSave =
        // _currentChartData.isEmpty
        //     ? 0
        //     : _currentChartData
        //     .map((data) => data.save)
        //     .reduce((a, b) => a + b);
        //final int totalBalance = totalIncome - totalExpense;

        return Scaffold(
          appBar: buildHeader(context, "Analysis", "/home-screen/notifications-screen"),
          backgroundColor: AppColors.caribbeanGreen,
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 37),
                child: const Column(
                  children: [
                    SizedBox(height: 10),
                    //buildCards(totalBalance, totalExpense),
                    SizedBox(height: 12),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.honeydew,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 37),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        _buildTabsSection(),
                        const SizedBox(height: 35),
                        _buildChartSection(_currentChartData, chartMaxY),
                        const SizedBox(height: 32),
                        _buildIncomeExpenseSection(totalIncome, totalExpense),
                        const SizedBox(height: 32),
                        _buildTargetsSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IntrinsicHeight buildCards(int totalBalance, int totalExpense) {
    return IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildBalanceCard(
                            iconPath: 'assets/IconComponents/Income.svg',
                            title: 'Total Balance',
                            amount:
                                '${totalBalance < 0 ? '-' : ''}\$${NumberFormat('#,###', 'en_US').format(totalBalance.abs())}',
                            amountColor:
                                totalBalance >= 0
                                    ? AppColors.fenceGreen
                                    : AppColors.oceanBlue,
                          ),
                        ),
                        Container(
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 36),
                          color: AppColors.lightGreen,
                        ),
                        Expanded(
                          child: _buildBalanceCard(
                            iconPath: 'assets/IconComponents/Expense.svg',
                            title: 'Total Expense',
                            amount:
                                '\$${NumberFormat('#,###', 'en_US').format((totalExpense.abs()))}',
                            amountColor: AppColors.oceanBlue,
                          ),
                        ),
                      ],
                    ),
                  );
  }

  // import 'package:finance_management/presentation/shared_data.dart';
  // import 'package:flutter/material.dart';
  // import 'package:flutter_svg/svg.dart';
  // import 'package:go_router/go_router.dart';
  // import 'package:intl/intl.dart';
  // import 'package:syncfusion_flutter_charts/charts.dart';
  //
  // // Abstract base class for all analysis types to share common properties (income, expense)
  // abstract class BaseAnalysis {
  //   final int income;
  //   final int expense;
  //
  //   BaseAnalysis(this.income, this.expense);
  //
  //   // Abstract getter for the x-axis value, to be implemented by concrete classes
  //   String get xValue;
  // }
  //
  // // Daily analysis data model
  // class DailyAnalysis extends BaseAnalysis {
  //   final DateTime day;
  //   final DateTime startDate;
  //   final DateTime endDate;
  //
  //   DailyAnalysis(this.day, this.startDate, this.endDate, int income, int expense)
  //       : super(income, expense);
  //
  //   // Returns the abbreviated day name (e.g., 'Mon', 'Tue') for the x-axis
  //   @override
  //   String get xValue => DateFormat('EEE').format(day);
  // }
  //
  // // Weekly analysis data model
  // class WeeklyAnalysis extends BaseAnalysis {
  //   final int weekNumber;
  //   final DateTime startDate;
  //   final DateTime endDate;
  //
  //   WeeklyAnalysis(this.weekNumber, this.startDate, this.endDate, int income, int expense)
  //       : super(income, expense);
  //
  //   // Returns a string like 'Week 1', 'Week 2' for the x-axis
  //   @override
  //   String get xValue => 'Week $weekNumber';
  // }
  //
  // // Monthly analysis data model
  // class MonthlyAnalysis extends BaseAnalysis {
  //   final int monthNumber;
  //   final DateTime startDate;
  //   final DateTime endDate;
  //
  //   MonthlyAnalysis(this.monthNumber, this.startDate, this.endDate, int income, int expense)
  //       : super(income, expense);
  //
  //   // Returns the abbreviated month name (e.g., 'Jan', 'Feb') for the x-axis
  //   @override
  //   String get xValue => DateFormat('MMM').format(DateTime(2025, monthNumber));
  // }
  //
  // // Yearly analysis data model
  // class YearAnalysis extends BaseAnalysis {
  //   final int year;
  //   final DateTime startDate;
  //   final DateTime endDate;
  //
  //   YearAnalysis(this.year, this.startDate, this.endDate, int income, int expense)
  //       : super(income, expense);
  //
  //   // Returns the year as a string for the x-axis
  //   @override
  //   String get xValue => year.toString();
  // }
  //
  // // Enum to represent the selected time filter
  // enum TimeFilter { daily, weekly, monthly, year }
  //
  // class AnalysisScreen extends StatefulWidget {
  //   static const String routeName = '/analysis-screen';
  //   final String searchScreenPath;
  //   final String calendarScreenPath;
  //
  //   //const HomeScreen({super.key, required this.label, required this.notificationsScreenPath});
  //   const AnalysisScreen({super.key, required this.searchScreenPath, required this.calendarScreenPath});
  //
  //   @override
  //   State<AnalysisScreen> createState() => _AnalysisScreenState();
  // }
  //
  // class _AnalysisScreenState extends State<AnalysisScreen> {
  //   final DateTime now = DateTime(2025, 5, 22, 14, 45);
  //   final TransactionRepository _transactionRepository = TransactionRepository();
  //
  //   TimeFilter _selectedTimeFilter = TimeFilter.daily; // Default to daily
  //   List<BaseAnalysis> _currentChartData = []; // Holds the data for the current filter
  //   List<TransactionModel> _allTransactions = [];
  //   bool _isLoading = true;
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //     _loadDataAndGenerate(); // Load transactions and generate initial data
  //   }
  //
  //   // Load transactions from repository and generate data
  //   Future<void> _loadDataAndGenerate() async {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //
  //     try {
  //       _allTransactions = await _transactionRepository.getTransactionsAPI();
  //       _generateData(); // Generate data after loading transactions
  //     } catch (e) {
  //       debugPrint('Error loading transactions: $e');
  //       _allTransactions = [];
  //       _generateData();
  //     } finally {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  //
  //   // Generates data based on the selected time filter using real transaction data
  //   void _generateData() {
  //     setState(() {
  //       switch (_selectedTimeFilter) {
  //         case TimeFilter.daily:
  //           _currentChartData = _generateDailyData();
  //           break;
  //         case TimeFilter.weekly:
  //           _currentChartData = _generateWeeklyData();
  //           break;
  //         case TimeFilter.monthly:
  //           _currentChartData = _generateMonthlyData();
  //           break;
  //         case TimeFilter.year:
  //           _currentChartData = _generateYearData();
  //           break;
  //       }
  //     });
  //   }
  //
  //   // Generate daily data from real transactions (last 7 days)
  //   List<DailyAnalysis> _generateDailyData() {
  //     List<DailyAnalysis> dailyData = [];
  //
  //     for (int i = 6; i >= 0; i--) {
  //       DateTime targetDate = now.subtract(Duration(days: i));
  //       DateTime startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
  //       DateTime endOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);
  //
  //       // Filter transactions for this specific day
  //       List<TransactionModel> dayTransactions = _allTransactions.where((transaction) {
  //         return transaction.time.isAfter(startOfDay.subtract(const Duration(milliseconds: 1))) &&
  //             transaction.time.isBefore(endOfDay.add(const Duration(milliseconds: 1)));
  //       }).toList();
  //
  //       int totalIncome = 0;
  //       int totalExpense = 0;
  //
  //       for (TransactionModel transaction in dayTransactions) {
  //         if (transaction.idCategory.moneyType == MoneyType.income) {
  //           totalIncome += transaction.amount;
  //         } else if (transaction.idCategory.moneyType == MoneyType.expense) {
  //           totalExpense += transaction.amount;
  //         }
  //         // Note: Save transactions are not included in income/expense analysis
  //       }
  //
  //       dailyData.add(DailyAnalysis(targetDate, startOfDay, endOfDay, totalIncome, totalExpense));
  //     }
  //
  //     return dailyData;
  //   }
  //
  //   // Generate weekly data from real transactions (last 4 weeks)
  //   List<WeeklyAnalysis> _generateWeeklyData() {
  //     List<WeeklyAnalysis> weeklyData = [];
  //
  //     for (int i = 3; i >= 0; i--) {
  //       DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
  //       DateTime endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  //
  //       // Filter transactions for this week
  //       List<TransactionModel> weekTransactions = _allTransactions.where((transaction) {
  //         return transaction.time.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) &&
  //             transaction.time.isBefore(endOfWeek.add(const Duration(milliseconds: 1)));
  //       }).toList();
  //
  //       int totalIncome = 0;
  //       int totalExpense = 0;
  //
  //       for (TransactionModel transaction in weekTransactions) {
  //         if (transaction.idCategory.moneyType == MoneyType.income) {
  //           totalIncome += transaction.amount;
  //         } else if (transaction.idCategory.moneyType == MoneyType.expense) {
  //           totalExpense += transaction.amount;
  //         }
  //       }
  //
  //       weeklyData.add(WeeklyAnalysis(4 - i, startOfWeek, endOfWeek, totalIncome, totalExpense));
  //     }
  //
  //     return weeklyData;
  //   }
  //
  //   // Generate monthly data from real transactions (last 5 months)
  //   List<MonthlyAnalysis> _generateMonthlyData() {
  //     List<MonthlyAnalysis> monthlyData = [];
  //
  //     for (int i = 4; i >= 0; i--) {
  //       DateTime targetMonth = DateTime(now.year, now.month - i, 1);
  //       DateTime startOfMonth = DateTime(targetMonth.year, targetMonth.month, 1);
  //       DateTime endOfMonth = DateTime(targetMonth.year, targetMonth.month + 1, 1).subtract(const Duration(milliseconds: 1));
  //
  //       // Filter transactions for this month
  //       List<TransactionModel> monthTransactions = _allTransactions.where((transaction) {
  //         return transaction.time.isAfter(startOfMonth.subtract(const Duration(milliseconds: 1))) &&
  //             transaction.time.isBefore(endOfMonth.add(const Duration(milliseconds: 1)));
  //       }).toList();
  //
  //       int totalIncome = 0;
  //       int totalExpense = 0;
  //
  //       for (TransactionModel transaction in monthTransactions) {
  //         if (transaction.idCategory.moneyType == MoneyType.income) {
  //           totalIncome += transaction.amount;
  //         } else if (transaction.idCategory.moneyType == MoneyType.expense) {
  //           totalExpense += transaction.amount;
  //         }
  //       }
  //
  //       monthlyData.add(MonthlyAnalysis(targetMonth.month, startOfMonth, endOfMonth, totalIncome, totalExpense));
  //     }
  //
  //     return monthlyData;
  //   }
  //
  //   // Generate yearly data from real transactions (last 4 years)
  //   List<YearAnalysis> _generateYearData() {
  //     List<YearAnalysis> yearlyData = [];
  //
  //     for (int i = 3; i >= 0; i--) {
  //       int targetYear = now.year - i;
  //       DateTime startOfYear = DateTime(targetYear, 1, 1);
  //       DateTime endOfYear = DateTime(targetYear, 12, 31, 23, 59, 59);
  //
  //       // Filter transactions for this year
  //       List<TransactionModel> yearTransactions = _allTransactions.where((transaction) {
  //         return transaction.time.isAfter(startOfYear.subtract(const Duration(milliseconds: 1))) &&
  //             transaction.time.isBefore(endOfYear.add(const Duration(milliseconds: 1)));
  //       }).toList();
  //
  //       int totalIncome = 0;
  //       int totalExpense = 0;
  //
  //       for (TransactionModel transaction in yearTransactions) {
  //         if (transaction.idCategory.moneyType == MoneyType.income) {
  //           totalIncome += transaction.amount;
  //         } else if (transaction.idCategory.moneyType == MoneyType.expense) {
  //           totalExpense += transaction.amount;
  //         }
  //       }
  //
  //       yearlyData.add(YearAnalysis(targetYear, startOfYear, endOfYear, totalIncome, totalExpense));
  //     }
  //
  //     return yearlyData;
  //   }
  //
  //   @override
  //   Widget build(BuildContext context) {
  //     if (_isLoading) {
  //       // return Scaffold(
  //       //   appBar: _buildHeader(context),
  //       //   backgroundColor: AppColors.caribbeanGreen,
  //       //   body: const Center(
  //       //     child: CircularProgressIndicator(
  //       //       valueColor: AlwaysStoppedAnimation<Color>(AppColors.fenceGreen),
  //       //     ),
  //       //   ),
  //       // );
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         LoadingUtils.showLoading(context, true);
  //       });
  //
  //     } else {
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         LoadingUtils.showLoading(context, false);
  //       });
  //
  //     }
  //
  //     // Calculate total income and expense from the current chart data
  //     final double maxYValue = _currentChartData.isEmpty
  //         ? 1000.0
  //         : _currentChartData
  //         .map((data) => [data.income, data.expense])
  //         .expand((pair) => pair)
  //         .reduce((a, b) => a > b ? a : b)
  //         .toDouble();
  //
  //     final double chartMaxY = (maxYValue * 1.2).ceilToDouble();
  //
  //     final int totalIncome = _currentChartData.isEmpty
  //         ? 0
  //         : _currentChartData
  //         .map((data) => data.income)
  //         .reduce((a, b) => a + b);
  //     final int totalExpense = _currentChartData.isEmpty
  //         ? 0
  //         : _currentChartData
  //         .map((data) => data.expense)
  //         .reduce((a, b) => a + b);
  //     final int totalBalance = totalIncome - totalExpense;
  //
  //     return Scaffold(
  //       appBar: _buildHeader(context),
  //       backgroundColor: AppColors.caribbeanGreen,
  //       body: Column(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 37),
  //             child: Column(
  //               children: [
  //                 const SizedBox(height: 10),
  //                 IntrinsicHeight(
  //                   child: Row(
  //                     children: [
  //                       Expanded(
  //                         child: _buildBalanceCard(
  //                           iconPath: 'assets/IconComponents/Income.svg',
  //                           title: 'Total Balance',
  //                           amount:
  //                           '${totalBalance < 0 ? '-' : ''}\$${NumberFormat('#,###', 'en_US').format(totalBalance.abs())}',
  //                           amountColor:
  //                           totalBalance >= 0
  //                               ? AppColors.fenceGreen
  //                               : AppColors.oceanBlue,
  //                         ),
  //                       ),
  //                       Container(
  //                         width: 1,
  //                         margin: const EdgeInsets.symmetric(horizontal: 36),
  //                         color: AppColors.lightGreen,
  //                       ),
  //                       Expanded(
  //                         child: _buildBalanceCard(
  //                           iconPath: 'assets/IconComponents/Expense.svg',
  //                           title: 'Total Expense',
  //                           amount:
  //                           '\$${NumberFormat('#,###', 'en_US').format((totalExpense.abs()))}',
  //                           amountColor: AppColors.oceanBlue,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(height: 12),
  //               ],
  //             ),
  //           ),
  //           Expanded(
  //             child: Container(
  //               decoration: const BoxDecoration(
  //                 color: AppColors.honeydew,
  //                 borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(40),
  //                   topRight: Radius.circular(40),
  //                 ),
  //               ),
  //               padding: const EdgeInsets.symmetric(horizontal: 37),
  //               child: SingleChildScrollView(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const SizedBox(height: 40),
  //                     _buildTabsSection(),
  //                     const SizedBox(height: 35),
  //                     _buildChartSection(_currentChartData, chartMaxY),
  //                     const SizedBox(height: 32),
  //                     _buildIncomeExpenseSection(totalIncome, totalExpense),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 25),
      child: Container(
        padding: const EdgeInsets.only(left: 38, right: 36, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            const Text(
              'Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.fenceGreen,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                //NOTTE
                // try {
                //   context
                //       .findAncestorStateOfType<
                //       BottomNavigationBarScaffoldState
                //   >()
                //       ?.goToNotifications();
                // } catch (e) {
                //   debugPrint('Error navigating to notifications: $e');
                // }
                context.push("/home-screen/notifications-screen");
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.honeydew,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  Assets.functionalIcon.vector.path,
                  height: 19,
                  width: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard({
    required String iconPath,
    required String title,
    required String amount,
    required Color amountColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.attach_money, color: AppColors.fenceGreen),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.blackHeader,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  // Builds the chart section, now accepting a generic list of BaseAnalysis
  Widget _buildChartSection(List<BaseAnalysis> chartData, double maxYValue) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Income & Expenses',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.fenceGreen,
                ),
              ),
              Row(
                children: [
                  // SvgPicture.asset(
                  //   Assets.iconComponents.variant3.path,
                  //   width: 25,
                  //   height: 25,
                  // ),
                  // const SizedBox(width: 4),
                  // SvgPicture.asset(
                  //   Assets.iconComponents.calender.path,
                  //   width: 25,
                  //   height: 25,
                  // ),
                  GestureDetector(
                    onTap: () {
                      context.push(widget.searchScreenPath);
                    },
                    child: SvgPicture.asset(
                      Assets.iconComponents.variant3.path,
                      width: 25,
                      height: 25,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      context.push(widget.calendarScreenPath);
                    },
                    child: SvgPicture.asset(
                      Assets.iconComponents.calender.path,
                      width: 25,
                      height: 25,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 200,
            child:
                chartData.isEmpty
                    ? const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(
                          color: AppColors.fenceGreen,
                          fontSize: 16,
                        ),
                      ),
                    )
                    : SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      primaryXAxis: const CategoryAxis(
                        labelStyle: TextStyle(color: AppColors.fenceGreen),
                        majorTickLines: MajorTickLines(width: 0),
                        majorGridLines: MajorGridLines(width: 0),
                        axisLine: AxisLine(
                          width: 1,
                          color: AppColors.fenceGreen,
                        ),
                      ),
                      primaryYAxis: NumericAxis(
                        maximum: maxYValue,
                        minimum: 0,
                        interval: maxYValue / 5,
                        axisLine: const AxisLine(width: 0),
                        majorTickLines: const MajorTickLines(width: 0),
                        majorGridLines: const MajorGridLines(
                          width: 1,
                          color: AppColors.lightBlue,
                          dashArray: [2, 2],
                        ),
                        labelStyle: const TextStyle(color: AppColors.lightBlue),
                        numberFormat: NumberFormat.compactSimpleCurrency(
                          locale: 'en_US',
                          name: '\$',
                        ),
                        axisLabelFormatter: (AxisLabelRenderDetails args) {
                          if (args.value == 0) {
                            return ChartAxisLabel('', args.textStyle);
                          } else {
                            return ChartAxisLabel(args.text, args.textStyle);
                          }
                        },
                      ),
                      series: <ColumnSeries<BaseAnalysis, String>>[
                        ColumnSeries<BaseAnalysis, String>(
                          name: 'Income',
                          enableTrackball: true,
                          dataSource: chartData,
                          xValueMapper: (BaseAnalysis data, _) => data.xValue,
                          yValueMapper: (BaseAnalysis data, _) => data.income,
                          width: 0.6,
                          spacing: 0.5,
                          color: AppColors.caribbeanGreen,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        ColumnSeries<BaseAnalysis, String>(
                          name: 'Expense',
                          enableTrackball: true,
                          dataSource: chartData,
                          xValueMapper: (BaseAnalysis data, _) => data.xValue,
                          yValueMapper: (BaseAnalysis data, _) => data.expense,
                          width: 0.6,
                          spacing: 0.5,
                          color: AppColors.oceanBlue,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                      trackballBehavior: TrackballBehavior(
                        lineColor: AppColors.fenceGreen,
                        enable: true,
                        activationMode: ActivationMode.singleTap,
                        tooltipSettings: const InteractiveTooltip(enable: true),
                        markerSettings: const TrackballMarkerSettings(
                          markerVisibility: TrackballVisibilityMode.hidden,
                          color: AppColors.honeydew,
                          height: 10,
                          width: 10,
                        ),
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TabButton(
            title: 'Daily',
            isSelected: _selectedTimeFilter == TimeFilter.daily,
            onTap: () {
              setState(() {
                _selectedTimeFilter = TimeFilter.daily;
                _generateData(
                  context.read<TransactionBloc>().state.allTransactions,
                ); // Regenerate data on tab change
              });
            },
          ),
          _TabButton(
            title: 'Weekly',
            isSelected: _selectedTimeFilter == TimeFilter.weekly,
            onTap: () {
              setState(() {
                _selectedTimeFilter = TimeFilter.weekly;
                _generateData(
                  context.read<TransactionBloc>().state.allTransactions,
                ); // Regenerate data on tab change
              });
            },
          ),
          _TabButton(
            title: 'Monthly',
            isSelected: _selectedTimeFilter == TimeFilter.monthly,
            onTap: () {
              setState(() {
                _selectedTimeFilter = TimeFilter.monthly;
                _generateData(
                  context.read<TransactionBloc>().state.allTransactions,
                ); // Regenerate data on tab change
              });
            },
          ),
          _TabButton(
            title: 'Year',
            isSelected: _selectedTimeFilter == TimeFilter.year,
            onTap: () {
              setState(() {
                _selectedTimeFilter = TimeFilter.year;
                _generateData(
                  context.read<TransactionBloc>().state.allTransactions,
                ); // Regenerate data on tab change
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseSection(int totalIncome, int totalExpense) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIncomeCard(totalIncome),
        const SizedBox(width: 94),
        _buildExpenseCard(totalExpense),
      ],
    );
  }

  Widget _buildIncomeCard(int incomeAmount) {
    return Column(
      children: [
        SvgPicture.asset(
          Assets.iconComponents.income.path,
          width: 25,
          height: 25,
          colorFilter: const ColorFilter.mode(
            AppColors.caribbeanGreen,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 5),
        const Text('Income', style: TextStyle(color: AppColors.fenceGreen)),
        Text(
          '\$${NumberFormat('#,###', 'en_US').format(incomeAmount.abs())}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.fenceGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(int expenseAmount) {
    return Column(
      children: [
        SvgPicture.asset(
          Assets.iconComponents.expense.path,
          width: 25,
          height: 25,
          colorFilter: const ColorFilter.mode(
            AppColors.oceanBlue,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 5),
        const Text('Expense', style: TextStyle(color: AppColors.oceanBlue)),
        Text(
          '\$${NumberFormat('#,###', 'en_US').format(expenseAmount.abs())}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.oceanBlue,
          ),
        ),
      ],
    );
  }
}

Widget _buildTargetsSection() {
  final categories = CategoryRepository.getAllCategories()
      .where((c) => c.moneyType == MoneyType.save)
      .toList();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'My Targets',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.fenceGreen,
        ),
      ),
      const SizedBox(height: 16),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.0,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final transactions = context.read<TransactionBloc>().state.allTransactions
              .where((t) => t.idCategory.id == category.id)
              .toList();
          final totalSaved = transactions.fold(0, (sum, t) => sum + t.amount);
          final progress = category.goalSave != null && category.goalSave! > 0
              ? (totalSaved / category.goalSave!).clamp(0.0, 1.0)
              : 0.0;
          final percentage = (progress * 100).round();
          return GestureDetector(
            onTap: () {
              context.push(CategoryDetailSaveScreen.routeName, extra: category);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 70,
                        width: 70,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.oceanBlue),
                          backgroundColor: AppColors.honeydew,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: AppColors.honeydew,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.categoryType,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.honeydew,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.caribbeanGreen : AppColors.lightGreen,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.fenceGreen,
          ),
        ),
      ),
    );
  }
}
