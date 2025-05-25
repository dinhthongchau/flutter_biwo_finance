import 'package:finance_management/presentation/screens/categories/category_detail/category_detail_save_screen.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:finance_management/presentation/widgets/build_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum TimeFilter { daily, weekly, monthly }

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home-screen';
  final String label;
  final String notificationsScreenPath;

  const HomeScreen({
    super.key,
    required this.label,
    required this.notificationsScreenPath,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TimeFilter _selectedTimeFilter = TimeFilter.monthly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildHeaderHome(context, widget.notificationsScreenPath),
      backgroundColor: AppColors.caribbeanGreen,
      body: SingleChildScrollView(
        child: Column(children: [_buildBody(context)]),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 37),
          child: Column(
            children: [
              const SizedBox(height: 41),
              _buildBalanceExpenseSection(),
              const SizedBox(height: 12),
              // _buildProgressFeedbackSection(),
              // const SizedBox(height: 32),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.honeydew,
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 37),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 33),
              _buildSavingsRevenueSection(),
              const SizedBox(height: 26),
              _buildTabsSection(),
              const SizedBox(height: 24),
              _buildTransactionSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceExpenseSection() {
    final numberFormat = NumberFormat('#,###', 'en_US');

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final totalBalance =state.financialsForSummary['totalBalance'];
        return IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildBalanceCard(
                  iconPath: 'assets/IconComponents/Income.svg',
                  title: 'Total Balance',
                  amount:
                  '${totalBalance! < 0 ? '-' : ''}${NumberFormatUtils.formatAmount(totalBalance.abs())}',
                  amountColor: AppColors.honeydew,
                ),
              ),
              _buildVerticalDivider(),
              Expanded(
                child: _buildBalanceCard(
                  iconPath: 'assets/IconComponents/Expense.svg',
                  title: 'Total Expense',
                  amount:
                      //'-${NumberFormatUtils.formatAmount(context.read<TransactionBloc>().getCurrentMonthExpense())}',
                      '\$${numberFormat.format(state.financialsForSummary['expense']!.abs())}',

                  amountColor: AppColors.oceanBlue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard({
    required String iconPath,
    required String title,
    required String amount,
    required Color amountColor,
  }) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: SvgPicture.asset(iconPath),
                ),
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
            Row(
              children: [
                Text(
                  //state is TransactionLoading ? '0' : amount,
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
            ),
          ],
        );
      },
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 36),
      color: AppColors.lightGreen,
    );
  }

  Widget _buildProgressFeedbackSection() {
    return Column(
      children: [
        _buildProgressIndicator(percentage: 30, amount: '\$20,000'),
        const SizedBox(height: 10),
        _buildFeedbackRow(),
      ],
    );
  }

  Widget _buildProgressIndicator({
    required double percentage,
    required String amount,
  }) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.fenceGreen,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                '${percentage.toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.honeydew,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 175, right: 24),
            decoration: BoxDecoration(
              color: AppColors.honeydew,
              borderRadius: BorderRadius.circular(30),
            ),
            height: double.infinity,
            alignment: Alignment.center,
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: AppColors.fenceGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackRow() {
    return Row(
      children: [
        SvgPicture.asset('assets/IconComponents/check.svg'),
        const SizedBox(width: 10),
        const Text(
          '30% Of Your Saving, Looks Good.',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.fenceGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsRevenueSection() {
    return Container(
      padding: const EdgeInsets.only(left: 37, right: 37, bottom: 22),
      decoration: BoxDecoration(
        color: AppColors.caribbeanGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: _buildSavingsWidget()),
          const SizedBox(width: 20),
          Expanded(flex: 6, child: _buildRevenueWidget()),
        ],
      ),
    );
  }

  Widget _buildSavingsWidget() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final totalSavings = state.allTransactions
            .where((t) => t.idCategory.moneyType == MoneyType.save)
            .fold(0, (sum, t) => sum + t.amount);
        final totalGoals = CategoryRepository.getAllCategories()
            .where((c) => c.moneyType == MoneyType.save)
            .map((c) => c.goalSave ?? 0)
            .fold(0, (a, b) => a + b);
        double progress =
            totalGoals > 0 ? (totalSavings / totalGoals).clamp(0.0, 1.0) : 0.0;

        String iconPath = Assets.iconComponents.vector7.path; // Default icon
        final savingsCategories =
            CategoryRepository.getAllCategories()
                .where((c) => c.moneyType == MoneyType.save)
                .toList();
        late final CategoryModel highestGoalCategory;
        // Find the category with the highest goalSave
        if (savingsCategories.isNotEmpty) {
          highestGoalCategory = savingsCategories.reduce(
            (a, b) => (a.goalSave ?? 0) > (b.goalSave ?? 0) ? a : b,
          );
          iconPath = _getCategoryIconPath(highestGoalCategory.categoryType);
        }

        return Container(
          height: 115,
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: AppColors.honeydew, width: 2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  context.push(
                    CategoryDetailSaveScreen.routeName,
                    extra: highestGoalCategory,
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.oceanBlue,
                        ),
                        backgroundColor: AppColors.honeydew,
                      ),
                    ),
                    SvgPicture.asset(iconPath, height: 30, width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Savings',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackHeader,
                ),
              ),
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackHeader,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCategoryIconPath(String categoryType) {
    switch (categoryType) {
      case 'Travel':
        return Assets.iconComponents.travel.path;
      case 'New House':
        return Assets.iconComponents.newHome.path;
      case 'Wedding':
        return Assets.iconComponents.weddingDay.path;
      case 'Other Savings':
        return Assets.iconComponents.travel.path;
      default:
        return Assets.iconComponents.vector7.path;
    }
  }

  Widget _buildAnimatedCircularProgress() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 0.5),
      duration: const Duration(milliseconds: 3500),
      builder: (context, value, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 70,
              width: 70,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 3,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.oceanBlue,
                ),
                backgroundColor: AppColors.honeydew,
              ),
            ),
            SvgPicture.asset(
              Assets.iconComponents.car.path,
              height: 30,
              width: 40,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRevenueWidget() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final transactionBloc = context.read<TransactionBloc>();

        final revenueLastWeek =
            state.allTransactions.isNotEmpty
                ? transactionBloc.getRevenueLastWeek()
                : 0;
        final foodLastWeek =
            state.allTransactions.isNotEmpty
                ? transactionBloc.getFoodLastWeek()
                : 0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRevenueItem(
              iconPath: 'assets/IconComponents/Vector-1.svg',
              title: 'Revenue Last Week',
              amount: '\$$revenueLastWeek',
              amountColor: AppColors.fenceGreen,
              showDivider: true,
            ),
            _buildRevenueItem(
              iconPath: 'assets/IconComponents/Salary.svg',
              title: 'Food Last Week',
              amount: '-\$$foodLastWeek',
              amountColor: AppColors.oceanBlue,
              showDivider: false,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRevenueItem({
    required String iconPath,
    required String title,
    required String amount,
    required Color amountColor,
    required bool showDivider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration:
          showDivider
              ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.honeydew, width: 2),
                ),
              )
              : null,
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(iconPath, height: 40, width: 40),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.fenceGreen,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
              ],
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
          _buildTab('Daily', _selectedTimeFilter == TimeFilter.daily),
          _buildTab('Weekly', _selectedTimeFilter == TimeFilter.weekly),
          _buildTab('Monthly', _selectedTimeFilter == TimeFilter.monthly),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    TimeFilter filter;
    switch (title.toLowerCase()) {
      case 'daily':
        filter = TimeFilter.daily;
        break;
      case 'weekly':
        filter = TimeFilter.weekly;
        break;
      case 'monthly':
        filter = TimeFilter.monthly;
        break;
      default:
        filter = TimeFilter.monthly;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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

  Widget _buildTransactionSection(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {},
      builder: (context, state) {
        // if (state is TransactionLoading) {
        //   return const Center(child: CircularProgressIndicator());
        // }
        if (state.allTransactions.isEmpty) {
          return const Center(child: Text('No transactions available.'));
        }

        List<TransactionModel> transactions = state.allTransactions;
        // DateTime now = DateTime.now();

        switch (_selectedTimeFilter) {
          case TimeFilter.daily:
            transactions.sort((a, b) => b.time.compareTo(a.time));
            break;
          case TimeFilter.weekly:
            transactions.sort((a, b) => b.time.compareTo(a.time));
            break;
          case TimeFilter.monthly:
            transactions = context
                .read<TransactionBloc>()
                .getTransactionsForDisplay(
                  state.allTransactions,
                  state.selectedMonth,
                  state.currentListFilterType,
                );

            transactions.sort((a, b) => b.time.compareTo(a.time));
            break;
        }

        Map<String, List<TransactionModel>> groupedTransactions = {};
        if (transactions.isNotEmpty) {
          for (var transaction in transactions) {
            String dateKey = '';
            if (_selectedTimeFilter == TimeFilter.daily) {
              dateKey = DateFormat('EEEE, d MMMM, y').format(transaction.time);
            } else if (_selectedTimeFilter == TimeFilter.weekly) {
              int day = transaction.time.day;
              String monthYear = DateFormat('MMMM, y').format(transaction.time);
              if (day >= 1 && day <= 7) {
                dateKey = 'Week 1, $monthYear';
              } else if (day >= 8 && day <= 15) {
                dateKey = 'Week 2, $monthYear';
              } else if (day >= 16 && day <= 22) {
                dateKey = 'Week 3, $monthYear';
              } else {
                dateKey = 'Week 4, $monthYear';
              }
            } else {
              dateKey = DateFormat('MMMM, y').format(transaction.time);
            }

            if (!groupedTransactions.containsKey(dateKey)) {
              groupedTransactions[dateKey] = [];
            }
            groupedTransactions[dateKey]!.add(transaction);
          }
        }

        List<String> sortedDateKeys = groupedTransactions.keys.toList();
        sortedDateKeys.sort((a, b) {
          DateTime dateA;
          DateTime dateB;

          if (_selectedTimeFilter == TimeFilter.daily) {
            dateA = DateFormat('EEEE, d MMMM, y').parse(a);
            dateB = DateFormat('EEEE, d MMMM, y').parse(b);
          } else if (_selectedTimeFilter == TimeFilter.weekly) {
            RegExp regExp = RegExp(r'Week (\d+), (\w+) (\d{4})');
            Match? matchA = regExp.firstMatch(a);
            Match? matchB = regExp.firstMatch(b);

            if (matchA != null && matchB != null) {
              int weekNumA = int.parse(matchA.group(1)!);
              String monthNameA = matchA.group(2)!;
              int yearA = int.parse(matchA.group(3)!);

              int weekNumB = int.parse(matchB.group(1)!);
              String monthNameB = matchB.group(2)!;
              int yearB = int.parse(matchB.group(3)!);

              DateTime tempDateA = DateTime(
                yearA,
                DateFormat('MMMM').parse(monthNameA).month,
                (weekNumA - 1) * 7 + 1,
              );
              DateTime tempDateB = DateTime(
                yearB,
                DateFormat('MMMM').parse(monthNameB).month,
                (weekNumB - 1) * 7 + 1,
              );

              return tempDateB.compareTo(tempDateA);
            }
            return 0;
          } else {
            dateA = DateFormat('MMMM, y').parse(a);
            dateB = DateFormat('MMMM, y').parse(b);
          }
          return dateB.compareTo(dateA);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transactions.isEmpty || state is TransactionLoading)
              const Center(child: Text('No transactions for this period.'))
            else
              ...sortedDateKeys.map((dateHeader) {
                List<TransactionModel> dailyTransactions =
                    groupedTransactions[dateHeader]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        dateHeader,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackHeader,
                        ),
                      ),
                    ),
                    ...dailyTransactions.map((transaction) {
                      final isIncome =
                          transaction.idCategory.moneyType == MoneyType.income;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: buildTransactionItem(
                          context: context,
                          transactionId: transaction.id,
                          title: transaction.title,
                          iconPath:
                              isIncome
                                  ? Assets.iconComponents.salaryWhite.path
                                  : _getExpenseIcon(
                                    transaction.idCategory.categoryType,
                                  ),
                          date: _formatDate(
                            transaction.time,
                            _selectedTimeFilter,
                          ),
                          label: transaction.idCategory.categoryType,
                          amount: '${isIncome ? '' : '-'}${transaction.amount}',
                          backgroundColor:
                              isIncome
                                  ? AppColors.lightBlue
                                  : AppColors.vividBlue,
                          showDividers: true,
                        ),
                      );
                    }),
                  ],
                );
              }),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date, TimeFilter filter) {
    return DateFormat('dd/MM/yy').format(date);
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
}
