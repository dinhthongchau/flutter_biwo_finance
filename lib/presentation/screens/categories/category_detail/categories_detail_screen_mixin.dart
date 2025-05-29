import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

mixin CategoriesDetailScreenMixin {
  String _getScreenTitle(CategoryModel category) {
    return '${category.categoryType} Transactions';
  }

  Widget buildBodyCategories(CategoryModel category) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final filteredTransactions =
        state.allTransactions
            .where((t) => t.idCategory.id == category.id)
            .toList();

        if (filteredTransactions.isEmpty) {
          return Center(
            child: Text(
              'No ${category.categoryType} transactions found.',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.blackHeader,
              ),
            ),
          );
        }

        final totalBalance = context
            .read<TransactionBloc>()
            .calculateTotalBalance(state.allTransactions);

        final totalCategoryAmount = _calculateTotalCategoryAmount(
          filteredTransactions,
        );

        Map<String, List<TransactionModel>> groupedTransactions = {};
        for (var t in filteredTransactions) {
          final monthYear = context.read<TransactionBloc>().getMonthName(
            t.time.month,
            t.time.year,
          );
          if (!groupedTransactions.containsKey(monthYear)) {
            groupedTransactions[monthYear] = [];
          }
          groupedTransactions[monthYear]!.add(t);
        }

        final sortedMonthYears =
        groupedTransactions.keys.toList()..sort((a, b) {
          final aParts = a.split(' ');
          final bParts = b.split(' ');
          final aMonthIndex =
              TransactionBloc.monthNames.indexOf(aParts[0]) + 1;
          final bMonthIndex =
              TransactionBloc.monthNames.indexOf(bParts[0]) + 1;
          final aDate = DateTime(int.parse(aParts[1]), aMonthIndex);
          final bDate = DateTime(int.parse(bParts[1]), bMonthIndex);
          return bDate.compareTo(aDate);
        });

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTotalBalanceCard(totalBalance)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTotalCategoryAmountCard(
                      totalCategoryAmount,
                      category.moneyType,
                    ),
                  ),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...sortedMonthYears.map((monthYear) {
                        final transactionsForMonth =
                        groupedTransactions[monthYear]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                              ),
                              child: Text(
                                monthYear,
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
                                    transaction.idCategory.moneyType ==
                                        MoneyType.income;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 16,
                                  ),
                                  child: buildTransactionItem(
                                    context: context,
                                    transactionId: transaction.id,
                                    title: transaction.title,
                                    iconPath:
                                    isIncome
                                        ? Assets
                                        .iconComponents
                                        .salaryWhite
                                        .path
                                        : getExpenseIcon(
                                      transaction
                                          .idCategory
                                          .categoryType,
                                    ),
                                    date:
                                    '${transaction.time.day.toString().padLeft(2, '0')} - ${transaction.time.hour.toString().padLeft(2, '0')}:${transaction.time.minute.toString().padLeft(2, '0')}',
                                    label:
                                    transaction
                                        .idCategory
                                        .categoryType,
                                    amount:
                                    '${isIncome ? '' : '-'}${transaction.amount}',
                                    backgroundColor:
                                    isIncome
                                        ? AppColors.lightBlue
                                        : AppColors.vividBlue,
                                    showDividers: false,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  AppBar buildAppBarCategories(BuildContext context,CategoryModel category) {
    return AppBar(
      backgroundColor: AppColors.caribbeanGreen,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.fenceGreen),
        onPressed: () => context.pop(),
      ),
      title: Text(
        _getScreenTitle(category),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.fenceGreen,
        ),
      ),
      centerTitle: true,
    );
  }

  GestureDetector buildFloatingCategoryDetail(BuildContext context, CategoryModel category) {
    return GestureDetector(
      onTap: () {
        context.push(AddTransactionScreen.routeName, extra: category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.caribbeanGreen,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.fenceGreen.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          category.moneyType == MoneyType.expense
              ? 'Add Transaction Expense'
              : category.moneyType == MoneyType.income
              ? 'Add Transaction Income'
              : 'Add Transaction Saving',
          style:
          Theme.of(
            context,
          ).elevatedButtonTheme.style?.textStyle?.resolve({}) ??
              const TextStyle(color: AppColors.honeydew, fontSize: 15),
        ),
      ),
    );
  }

  int _calculateTotalCategoryAmount(List<TransactionModel> transactions) {
    int total = 0;
    for (var transaction in transactions) {
      total += transaction.amount;
    }
    return total;
  }

  Widget _buildTotalBalanceCard(int totalBalance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.honeydew,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.fenceGreen.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.blackHeader,
            ),
          ),
          Text(
            '${totalBalance < 0 ? '-' : ''}\$${totalBalance.abs()}',
            //'\$${totalBalance.abs()}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:
              totalBalance >= 0
                  ? AppColors.caribbeanGreen
                  : AppColors.oceanBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCategoryAmountCard(int totalAmount, MoneyType type) {
    String title;
    Color color;

    switch (type) {
      case MoneyType.income:
        title = 'Total Income';
        color = AppColors.caribbeanGreen;
        break;
      case MoneyType.expense:
        title = 'Total Expenses';
        color = AppColors.oceanBlue;
        break;
      case MoneyType.save:
        title = 'Total Savings';
        color = AppColors.lightBlue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.honeydew,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.fenceGreen.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.blackHeader,
            ),
          ),
          Text(
            '\$${totalAmount.abs()}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  AppBar buildAppBarSave(BuildContext context, CategoryModel category) {
    return AppBar(
      backgroundColor: AppColors.caribbeanGreen,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.fenceGreen),
        onPressed: () => context.pop(),
      ),
      title: Text(
        _getScreenTitle(category),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.fenceGreen,
        ),
      ),
      centerTitle: true,
    );
  }

  GestureDetector buildFloatingCategorySave(BuildContext context, CategoryModel category) {
    return GestureDetector(
      onTap: () {
        context.push(AddTransactionScreen.routeName, extra: category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.caribbeanGreen,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.fenceGreen.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          category.moneyType == MoneyType.expense
              ? 'Add Transaction Expense'
              : category.moneyType == MoneyType.income
              ? 'Add Transaction Income'
              : 'Add Transaction Saving',
          style:
          Theme.of(
            context,
          ).elevatedButtonTheme.style?.textStyle?.resolve({}) ??
              const TextStyle(color: AppColors.honeydew, fontSize: 15),
        ),
      ),
    );
  }

  Widget buildBodySave( CategoryModel category) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final filteredTransactions =
        state.allTransactions
            .where((t) => t.idCategory.id == category.id)
            .toList();

        if (filteredTransactions.isEmpty) {
          return Center(
            child: Text(
              'No ${category.categoryType} savings found.',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.blackHeader,
              ),
            ),
          );
        }

        final totalCategoryAmount = _calculateTotalCategoryAmount(
          filteredTransactions,
        );

        Map<String, List<TransactionModel>> groupedTransactions = {};
        for (var t in filteredTransactions) {
          final monthYear = context.read<TransactionBloc>().getMonthName(
            t.time.month,
            t.time.year,
          );
          if (!groupedTransactions.containsKey(monthYear)) {
            groupedTransactions[monthYear] = [];
          }
          groupedTransactions[monthYear]!.add(t);
        }

        final sortedMonthYears =
        groupedTransactions.keys.toList()..sort((a, b) {
          final aParts = a.split(' ');
          final bParts = b.split(' ');
          final aMonthIndex =
              TransactionBloc.monthNames.indexOf(aParts[0]) + 1;
          final bMonthIndex =
              TransactionBloc.monthNames.indexOf(bParts[0]) + 1;
          final aDate = DateTime(int.parse(aParts[1]), aMonthIndex);
          final bDate = DateTime(int.parse(bParts[1]), bMonthIndex);
          return bDate.compareTo(aDate);
        });

        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.honeydew,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 37,
                  vertical: 33,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSavingsWidget(totalCategoryAmount, category),
                      const SizedBox(height: 12),
                      _buildProgressFeedbackSection(totalCategoryAmount, category),
                      const SizedBox(height: 32),
                      ...sortedMonthYears.map((monthYear) {
                        final transactionsForMonth =
                        groupedTransactions[monthYear]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                              ),
                              child: Text(
                                monthYear,
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
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 16,
                                  ),
                                  child: buildTransactionItem(
                                    context: context,
                                    transactionId: transaction.id,
                                    title: transaction.title,
                                    iconPath: getCategoryIconPath(
                                      transaction.idCategory.categoryType,
                                    ),
                                    date:
                                    '${transaction.time.day.toString().padLeft(2, '0')} - ${transaction.time.hour.toString().padLeft(2, '0')}:${transaction.time.minute.toString().padLeft(2, '0')}',
                                    label:
                                    transaction.idCategory.categoryType,
                                    amount: '\$${transaction.amount}',
                                    backgroundColor: AppColors.lightBlue,
                                    showDividers: false,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressFeedbackSection(int totalSavings , CategoryModel category) {
    double progress =
    category.goalSave != null && category.goalSave! > 0
        ? (totalSavings / category.goalSave!).clamp(0.0, 1.0)
        : 0.0;
    int percentage = (progress * 100).round();
    String getSavingsMessage(int percentage) {
      if (percentage <= 20) {
        return '$percentage% of Your Saving, Needs More.';
      } else if (percentage <= 40) {
        return '$percentage% of Your Saving, Keep Going.';
      } else if (percentage <= 60) {
        return '$percentage% of Your Saving, Good Progress.';
      } else if (percentage <= 80) {
        return '$percentage% of Your Saving, Great Job!';
      } else {
        return '$percentage% of Your Saving, Outstanding!';
      }
    }

    return Column(
      children: [
        Container(
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
                    '$percentage%',
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
                  color: AppColors.caribbeanGreen,
                  borderRadius: BorderRadius.circular(30),
                ),
                height: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  '\$${category.goalSave?.toInt() ?? 0}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: AppColors.honeydew,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              SvgPicture.asset('assets/IconComponents/check.svg'),
              const SizedBox(width: 10),
              Text(
                getSavingsMessage(percentage),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.fenceGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsWidget(int totalSavings, CategoryModel category) {
    double progress =
    category.goalSave != null && category.goalSave! > 0
        ? (totalSavings / category.goalSave!).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSavingsItem(
                  iconPath: Assets.iconComponents.vector7.path,
                  title: 'Goal',

                  amount: NumberFormatUtils.formatAmount(
                    category.goalSave?.toInt() ?? 0,
                  ),
                  amountColor: AppColors.fenceGreen,
                  showDivider: true,
                ),
                _buildSavingsItem(
                  iconPath: Assets.iconComponents.vector7.path,
                  title: 'Amount Saved',
                  amount: NumberFormatUtils.formatAmount(totalSavings),
                  amountColor: AppColors.caribbeanGreen,
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.oceanBlue,
                          ),
                          backgroundColor: AppColors.honeydew,
                        ),
                      ),
                      SvgPicture.asset(
                        getCategoryIconPath(category.categoryType),
                        height: 30,
                        width: 40,
                        colorFilter: const ColorFilter.mode(
                          AppColors.honeydew,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    category.categoryType,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.honeydew,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsItem({
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 12,
                      width: 12,
                      child: SvgPicture.asset(iconPath),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.fenceGreen,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(width: 15),
                    Text(
                      amount,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}