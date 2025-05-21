import 'package:finance_management/data/model/category_model.dart';
import 'package:finance_management/data/model/transaction_model.dart';
import 'package:finance_management/data/repositories/transaction_repository.dart';
import 'package:finance_management/gen/assets.gen.dart';
import 'package:finance_management/presentation/routes.dart'; // Assuming this provides BottomNavigationBarScaffoldState
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TransactionScreen extends StatefulWidget {
  static const String routeName = "/transaction-screen";

  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late Future<List<TransactionModel>> _transactionsFuture;
  String _selectedMonth = 'All';
  List<String> _availableMonths = ['All'];
  DateTime _now = DateTime.now();
  // This filter type controls which transactions are shown in the list below the financial summary.
  // It does NOT affect the financial summary calculations (Total Balance, Income, Expense).
  MoneyType? _currentListFilterType; // null for 'All', MoneyType.Income, MoneyType.Expense

  // Define the month names as a constant list
  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    _transactionsFuture = TransactionRepository().getTransactionsAPI();
    final transactions = await _transactionsFuture;

    final months =
    transactions
        .map((t) => DateTime(t.time.year, t.time.month))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    _availableMonths =
        ['All'] +
            months.map((date) => _getMonthName(date.month, date.year)).toList();

    setState(() {
      _selectedMonth = 'All'; // Set default to 'All'
      if (!_availableMonths.contains('All')) {
        _availableMonths.insert(0, 'All');
      }
    });
  }

  String _getMonthName(int month, int year) {
    // Use the constant list here
    return '${_monthNames[month - 1]} $year';
  }

  // This function filters transactions for the *list display* based on month and selected type (Income/Expense).
  List<TransactionModel> _getTransactionsForDisplay(
      List<TransactionModel> allTransactions) {
    List<TransactionModel> monthlyFiltered = [];

    if (_selectedMonth == 'All') {
      monthlyFiltered = allTransactions;
    } else {
      final parts = _selectedMonth.split(' ');
      final monthName = parts[0];
      final year = int.tryParse(parts[1]);
      final selectedMonthIndex = _monthNames.indexOf(monthName) + 1; // Use the constant list here

      monthlyFiltered = allTransactions
          .where((t) => t.time.month == selectedMonthIndex && t.time.year == year)
          .toList();
    }

    if (_currentListFilterType != null) {
      // Apply the type filter if one is selected
      return monthlyFiltered
          .where((t) => t.idCategory.moneyType == _currentListFilterType)
          .toList();
    } else {
      // If no type filter is selected, show all Income and Expense transactions (exclude Save)
      return monthlyFiltered.where((t) => t.idCategory.moneyType != MoneyType.Save).toList();
    }
  }

  // This function calculates the cumulative balance up to the selected month,
  // and also the income/expense/save for the *selected month only* (or all if 'All' is selected).
  Map<String, int> _calculateCumulativeFinancials(List<TransactionModel> allTransactions) {
    int cumulativeBalance = 0;
    int monthlyIncome = 0;
    int monthlyExpense = 0;
    int monthlySave = 0;

    // Sort transactions chronologically to ensure correct cumulative calculation
    allTransactions.sort((a, b) => a.time.compareTo(b.time));

    // Determine the target month and year for monthly financials
    int targetMonth = -1;
    int targetYear = -1;
    if (_selectedMonth != 'All') {
      final parts = _selectedMonth.split(' ');
      final monthName = parts[0];
      final year = int.tryParse(parts[1]);
      if (year != null) {
        targetMonth = _monthNames.indexOf(monthName) + 1;
        targetYear = year;
      }
    }

    for (final t in allTransactions) {
      // Calculate cumulative balance for all transactions up to the selected month (or all if 'All')
      bool includeInCumulative = false;
      if (_selectedMonth == 'All') {
        includeInCumulative = true;
      } else if (targetMonth != -1 && targetYear != -1) {
        // Check if transaction is in or before the target month/year
        if (t.time.year < targetYear || (t.time.year == targetYear && t.time.month <= targetMonth)) {
          includeInCumulative = true;
        }
      }

      if (includeInCumulative) {
        if (t.idCategory.moneyType == MoneyType.Income) {
          cumulativeBalance += t.amount;
        } else if (t.idCategory.moneyType == MoneyType.Expense) {
          cumulativeBalance -= t.amount;
        } else if (t.idCategory.moneyType == MoneyType.Save) {
          cumulativeBalance -= t.amount; // Savings reduce the available balance
        }
      }

      // Calculate monthly income/expense/save for the summary cards
      if (_selectedMonth == 'All') {
        // If 'All' is selected, sum up all income/expense/save for the summary cards
        if (t.idCategory.moneyType == MoneyType.Income) {
          monthlyIncome += t.amount;
        } else if (t.idCategory.moneyType == MoneyType.Expense) {
          monthlyExpense += t.amount;
        } else if (t.idCategory.moneyType == MoneyType.Save) {
          monthlySave += t.amount;
        }
      } else if (t.time.month == targetMonth && t.time.year == targetYear) {
        // If a specific month is selected, only sum for that month
        if (t.idCategory.moneyType == MoneyType.Income) {
          monthlyIncome += t.amount;
        } else if (t.idCategory.moneyType == MoneyType.Expense) {
          monthlyExpense += t.amount;
        } else if (t.idCategory.moneyType == MoneyType.Save) {
          monthlySave += t.amount;
        }
      }
    }

    return {
      'totalBalance': cumulativeBalance,
      'income': monthlyIncome,
      'expense': monthlyExpense,
      'save': monthlySave,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildHeader(context),
      backgroundColor: AppColors.caribbeanGreen,
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions available.'));
          }

          final allTransactions = snapshot.data!;

          // Calculate cumulative financials (total balance, and current month's income/expense/save)
          final financialsForSummary = _calculateCumulativeFinancials(allTransactions); // Use the new function

          // Get transactions for the list display (filtered by month and type)
          final transactionsForListDisplay = _getTransactionsForDisplay(allTransactions);

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildBody(
                  context,
                  financialsForSummary['totalBalance']!, // Use cumulative balance
                  financialsForSummary['income']!,      // Use current month's income
                  financialsForSummary['expense']!,     // Use current month's expense
                  financialsForSummary['save']!,        // Use current month's save
                  transactionsForListDisplay,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 25),
      child: Container(
        padding: const EdgeInsets.only(left: 38, right: 36, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.fenceGreen),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              'Transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.fenceGreen,
              ),
            ),
            GestureDetector(
              onTap: () {
                try {
                  context
                      .findAncestorStateOfType<
                      BottomNavigationBarScaffoldState
                  >()
                      ?.goToNotifications();
                } catch (e) {
                  print('Error navigating to notifications: $e');
                }
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

  Widget _buildBody(
      BuildContext context,
      int totalBalance,
      int income,
      int expense,
      int saveAmount, // Added saveAmount parameter
      List<TransactionModel> transactions, // This list is already filtered for display
      ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            children: [
              const SizedBox(height: 31),
              _buildBalanceExpenseSection(totalBalance, income, expense, saveAmount),
              const SizedBox(height: 23),
            ],
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.honeydew,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 37),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildTransactionSection(transactions)],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceExpenseSection(
      int totalBalance,
      int income,
      int expense,
      int saveAmount, // Added saveAmount parameter
      ) {
    return IntrinsicHeight(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _currentListFilterType = null; // Set filter to show all (Income/Expense)
              });
            },
            child: _buildBalanceCard(
              iconPath: '',
              title: 'Total Balance',
              amount: '\$${totalBalance.abs()}.00',
              amountColor:
              totalBalance >= 0 ? AppColors.fenceGreen : AppColors.oceanBlue,
              isSelected: _currentListFilterType == null, // Highlight if 'All' is selected
              savingAmount: saveAmount, // Pass the save amount
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentListFilterType = MoneyType.Income; // Set filter to show only Income
                    });
                  },
                  child: _buildBalanceCard(
                    iconPath: Assets.iconComponents.income.path,
                    title: 'Income',
                    amount: '\$$income.00',
                    amountColor: AppColors.caribbeanGreen,
                    isSelected: _currentListFilterType == MoneyType.Income,
                  ),
                ),
              ),
              _buildVerticalDivider(),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentListFilterType = MoneyType.Expense; // Set filter to show only Expense
                    });
                  },
                  child: _buildBalanceCard(
                    iconPath: Assets.iconComponents.expense.path,
                    title: 'Expense',
                    amount: '\$$expense.00',
                    amountColor: AppColors.oceanBlue,
                    isSelected: _currentListFilterType == MoneyType.Expense,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard({
    required String iconPath,
    required String title,
    required String amount,
    required Color amountColor,
    required bool isSelected,
    int? savingAmount, // New optional parameter for saving amount
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.oceanBlue : AppColors.honeydew,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconPath.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 4),
              child: SvgPicture.asset(
                iconPath,
                width: 25,
                height: 25,
                color: isSelected ? AppColors.honeydew : amountColor,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.honeydew : AppColors.blackHeader,
                ),
              ),
            ],
          ),
          // Conditionally display saving amount only for 'Total Balance'
          if (title == 'Total Balance' && savingAmount != null)
            Column(
              children: [
                Text(
                  amount,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.honeydew : amountColor,
                  ),
                ),
                Text(
                  '(Saving: \$${savingAmount.abs()}.00)', // Display saving amount
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.honeydew.withOpacity(0.8) : AppColors.oceanBlue,
                  ),
                ),
              ],
            )
          else
            Text(
              amount,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.honeydew : amountColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      margin: const EdgeInsets.only(right: 15),
      color: AppColors.lightGreen,
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Now selected is: ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fenceGreen,
                ),
              ),
              TextSpan(
                text: _selectedMonth,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.fenceGreen,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (month) {
            setState(() {
              _selectedMonth = month;
            });
          },
          itemBuilder:
              (context) =>
              _availableMonths.map((month) {
                return PopupMenuItem(value: month, child: Text(month));
              }).toList(),
          child: const Icon(Icons.calendar_today, color: AppColors.fenceGreen),
        ),
      ],
    );
  }

  Widget _buildTransactionSection(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50.0),
        child: Center(
          child: Text(
            'No transactions for this month.',
            style: TextStyle(fontSize: 16, color: AppColors.blackHeader),
          ),
        ),
      );
    }

    // Group transactions by month and year for display
    Map<String, List<TransactionModel>> groupedTransactions = {};
    for (var t in transactions) {
      final monthYear = _getMonthName(t.time.month, t.time.year);
      if (!groupedTransactions.containsKey(monthYear)) {
        groupedTransactions[monthYear] = [];
      }
      groupedTransactions[monthYear]!.add(t);
    }

    // Sort the month-year keys from newest to oldest
    final sortedMonthYears =
    groupedTransactions.keys.toList()..sort((a, b) {
      final aParts = a.split(' ');
      final bParts = b.split(' ');
      final aMonthIndex = _monthNames.indexOf(aParts[0]) + 1;
      final bMonthIndex = _monthNames.indexOf(bParts[0]) + 1;
      final aDate = DateTime(int.parse(aParts[1]), aMonthIndex);
      final bDate = DateTime(int.parse(bParts[1]), bMonthIndex);
      return bDate.compareTo(aDate);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 27.0, bottom: 24),
          child: _buildMonthSelector(),
        ),
        // Iterate through sorted months and build sections for each month
        ...sortedMonthYears.map((monthYear) {
          final transactionsForMonth = groupedTransactions[monthYear]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  monthYear, // Display month name (e.g., "May 2023")
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.fenceGreen,
                  ),
                ),
              ),
              Column(
                children:
                transactionsForMonth.map((transaction) {
                  final isIncome =
                      transaction.idCategory.moneyType == MoneyType.Income;
                  // MoneyType.Save transactions are already filtered out by _getTransactionsForDisplay
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTransactionItem(
                      title: transaction.title,
                      iconPath:
                      isIncome
                          ? Assets.iconComponents.salaryWhite.path
                          : _getExpenseIcon(
                        transaction.idCategory.categoryType,
                      ),
                      date:
                      '${transaction.time.day.toString().padLeft(2, '0')} - ${transaction.time.hour.toString().padLeft(2, '0')}:${transaction.time.minute.toString().padLeft(2, '0')}', // Display day and time
                      label: transaction.idCategory.categoryType,
                      amount:
                      '${isIncome ? '' : '-'}${transaction.amount}.00', // Prefix with '-' for expense
                      backgroundColor:
                      isIncome
                          ? AppColors.lightBlue
                          : AppColors.vividBlue,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  String _getExpenseIcon(String category) {
    switch (category) {
      case 'Groceries':
        return Assets.iconComponents.groceriesWhite.path;
      case 'Rent':
        return Assets.iconComponents.rentWhite.path;
      case 'Transport':
        return Assets.iconComponents.iconTransport.path;
      default:
        return Assets.iconComponents.expense.path;
    }
  }

  Widget _buildTransactionItem({
    required String title,
    required String iconPath,
    required String date,
    required String label,
    required String amount,
    required Color backgroundColor,
  }) {
    final isNegativeAmount = amount.startsWith('-');
    final displayAmount =
    isNegativeAmount ? '-\$${amount.substring(1)}' : '\$$amount';
    final amountColor =
    isNegativeAmount ? AppColors.oceanBlue : AppColors.caribbeanGreen;

    return Row(
      children: [
        _buildTransactionIcon(
          iconPath: iconPath,
          backgroundColor: backgroundColor,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fenceGreen,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.oceanBlue,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: AppColors.caribbeanGreen.withOpacity(0.3),
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        Expanded( // Added Expanded here to ensure even space distribution
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.fenceGreen,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: AppColors.caribbeanGreen.withOpacity(0.3),
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        Expanded( // Added Expanded here to ensure even space distribution
          child: Text(
            displayAmount,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionIcon({
    required String iconPath,
    required Color backgroundColor,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: SvgPicture.asset(
          iconPath,
          width: 20,
          height: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}