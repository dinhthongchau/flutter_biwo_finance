import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:finance_management/presentation/shared_data.dart';

mixin HomeScreenMixin {
  Widget buildFloatingActionButtonChatbotFinance(
    BuildContext context,
    chatbotFinanceScreenPath,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 100),
      child: GestureDetector(
        onTap: () {
          context.push(chatbotFinanceScreenPath);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.caribbeanGreen, AppColors.oceanBlue],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.oceanBlue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Robot icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Stack(
                  children: [
                    // Robot eyes
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.oceanBlue,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.oceanBlue,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                    // Robot mouth
                    Positioned(
                      bottom: 8,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.caribbeanGreen,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    // Robot antenna
                    Positioned(
                      top: 2,
                      left: 14,
                      child: Container(
                        width: 2,
                        height: 4,
                        color: AppColors.fenceGreen,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 13,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.fenceGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Chat AI text
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chat AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Trợ lý tài chính',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Status indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.honeydew,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.honeydew.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Phiên bản compact hơn nếu cần
  Widget buildFloatingActionButtonChatbotFinanceCompact(
    BuildContext context,
    chatbotFinanceScreenPath,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 100),
      child: GestureDetector(
        onTap: () {
          context.push(chatbotFinanceScreenPath);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.caribbeanGreen, AppColors.oceanBlue],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.oceanBlue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Robot icon nhỏ gọn
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        width: 2,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.oceanBlue,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 2,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.oceanBlue,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 8,
                      right: 8,
                      child: Container(
                        height: 1,
                        color: AppColors.caribbeanGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Text rõ ràng
              const Text(
                'Chat AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              // Online indicator
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.honeydew,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
                _buildTabsSection(context),
                const SizedBox(height: 24),
                _buildTransactionSection(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceExpenseSection() {
    final numberFormat = NumberFormat('#,###', 'en_US');

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final totalBalance = state.financialsForSummary['totalBalance'];
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.blackHeader,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    amount,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
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
        if (savingsCategories.isNotEmpty) {
          highestGoalCategory = savingsCategories.reduce(
            (a, b) => (a.goalSave ?? 0) > (b.goalSave ?? 0) ? a : b,
          );
          iconPath = getCategoryIconPath(highestGoalCategory.categoryType);
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

  Widget _buildTabsSection(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTab(
                context,
                'Daily',
                state.selectedTimeFilter == TimeFilterHome.daily,
              ),
              _buildTab(
                context,
                'Weekly',
                state.selectedTimeFilter == TimeFilterHome.weekly,
              ),
              _buildTab(
                context,
                'Monthly',
                state.selectedTimeFilter == TimeFilterHome.monthly,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(BuildContext context, String title, bool isSelected) {
    TimeFilterHome filter;
    switch (title.toLowerCase()) {
      case 'daily':
        filter = TimeFilterHome.daily;
        break;
      case 'weekly':
        filter = TimeFilterHome.weekly;
        break;
      case 'monthly':
        filter = TimeFilterHome.monthly;
        break;
      default:
        filter = TimeFilterHome.monthly;
    }
    return GestureDetector(
      onTap: () {
        context.read<HomeBloc>().add(SelectTimeFilterEvent(filter));
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
      builder: (context, transactionState) {
        return BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            if (homeState is HomeLoading) {
              return Center(child: LoadingUtils.buildSpinKitSpinningLines());
            }
            if (homeState is HomeError) {
              return Center(child: Text('Error: ${homeState.errorMessage ?? "Unknown error"}'));
            }
            if (transactionState.allTransactions.isEmpty) {
              return const Center(child: Text('No transactions available.'));
            }

            List<TransactionModel> transactions = transactionState.allTransactions;

            switch (homeState.selectedTimeFilter) {
              case TimeFilterHome.daily:
                transactions.sort((a, b) => b.time.compareTo(a.time));
                break;
              case TimeFilterHome.weekly:
                transactions.sort((a, b) => b.time.compareTo(a.time));
                break;
              case TimeFilterHome.monthly:
                transactions = context
                    .read<TransactionBloc>()
                    .getTransactionsForDisplay(
                  transactionState.allTransactions,
                  transactionState.selectedMonth,
                  transactionState.currentListFilterType,
                );
                transactions.sort((a, b) => b.time.compareTo(a.time));
                break;
            }

            Map<String, List<TransactionModel>> groupedTransactions = {};
            for (var transaction in transactions) {
              String dateKey = '';
              if (homeState.selectedTimeFilter == TimeFilterHome.daily) {
                dateKey = DateFormat('EEEE, d MMMM, y').format(transaction.time);
              } else if (homeState.selectedTimeFilter == TimeFilterHome.weekly) {
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
              groupedTransactions.putIfAbsent(dateKey, () => []).add(transaction);
            }

            List<String> sortedDateKeys = groupedTransactions.keys.toList();
            sortedDateKeys.sort((a, b) {
              DateTime dateA;
              DateTime dateB;
              if (homeState.selectedTimeFilter == TimeFilterHome.daily) {
                dateA = DateFormat('EEEE, d MMMM, y').parse(a);
                dateB = DateFormat('EEEE, d MMMM, y').parse(b);
              } else if (homeState.selectedTimeFilter == TimeFilterHome.weekly) {
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

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.isEmpty || transactionState is TransactionLoading
                  ? 1
                  : sortedDateKeys.length,
              itemBuilder: (context, index) {
                if (transactions.isEmpty || transactionState is TransactionLoading) {
                  return const Center(child: Text('No transactions for this period.'));
                }

                final dateHeader = sortedDateKeys[index];
                final dailyTransactions = groupedTransactions[dateHeader]!;

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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dailyTransactions.length,
                      itemBuilder: (context, transactionIndex) {
                        final transaction = dailyTransactions[transactionIndex];
                        final isIncome = transaction.idCategory.moneyType == MoneyType.income;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: buildTransactionItem(
                            context: context,
                            transactionId: transaction.id,
                            title: transaction.title,
                            iconPath: isIncome
                                ? Assets.iconComponents.salaryWhite.path
                                : getExpenseIcon(transaction.idCategory.categoryType),
                            date: _formatDate(transaction.time, homeState.selectedTimeFilter),
                            label: transaction.idCategory.categoryType,
                            amount: '${isIncome ? '' : '-'}${transaction.amount}',
                            backgroundColor: isIncome ? AppColors.lightBlue : AppColors.vividBlue,
                            showDividers: true,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date, TimeFilterHome filter) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

}
