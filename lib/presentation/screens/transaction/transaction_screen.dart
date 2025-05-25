  import 'package:finance_management/presentation/shared_data.dart';
import 'package:finance_management/presentation/widgets/build_app_bar.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:flutter_svg/svg.dart';
  import 'package:go_router/go_router.dart';

  class TransactionScreen extends StatefulWidget {
    static const String routeName = "/transaction-screen";

    const TransactionScreen({super.key});

    @override
    State<TransactionScreen> createState() => _TransactionScreenState();
  }

  class _TransactionScreenState extends State<TransactionScreen> {
    @override
    void initState() {
      super.initState();

      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   context.read<TransactionBloc>().add(const LoadTransactionsEvent());
      // });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: buildHeader(context, "Transaction", "/home-screen/notifications-screen"),
        backgroundColor: AppColors.caribbeanGreen,
        body: BlocConsumer<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is TransactionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ?? 'An unknown error occurred',
                  ),
                ),
              );
            }
            if (state is TransactionLoading) {

            }
          },
          builder: (context, state) {
            // if (state is TransactionLoading) {
            //   return _buildBody(context, 0, 0, 0, 0, [], '', [], null);
            // }

            if (state.allTransactions.isEmpty) {
              return const Center(child: Text('No transactions available.'));
            }

            final transactionsForListDisplay = context
                .read<TransactionBloc>()
                .getTransactionsForDisplay(
                  state.allTransactions,
                  state.selectedMonth,
                  state.currentListFilterType,
                );

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildBody(
                    context,
                    state.financialsForSummary['totalBalance']!,
                    state.financialsForSummary['income']!,
                    state.financialsForSummary['expense']!,
                    state.financialsForSummary['save']!,
                    transactionsForListDisplay,
                    state.selectedMonth,
                    state.availableMonths,
                    state.currentListFilterType,
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
              const Spacer(),
              const Text(
                'Transaction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fenceGreen,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  try {
                    context.push("/home-screen/notifications-screen");
                  } catch (e) {
                    debugPrint('Error navigating to notifications: $e');
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
      int saveAmount,
      List<TransactionModel> transactions,
      String selectedMonth,
      List<String> availableMonths,
      MoneyType? currentListFilterType,
    ) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              children: [
                const SizedBox(height: 31),
                _buildBalanceExpenseSection(
                  totalBalance,
                  income,
                  expense,
                  saveAmount,
                  currentListFilterType,
                ),
                const SizedBox(height: 23),
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
                _buildTransactionSection(
                  transactions,
                  selectedMonth,
                  availableMonths,
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget _buildBalanceExpenseSection(
      int totalBalance,
      int income,
      int expense,
      int saveAmount,
      MoneyType? currentListFilterType,
    ) {
      return IntrinsicHeight(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                context.read<TransactionBloc>().add(
                  const SelectFilterTypeEvent(null),
                );
              },
              child: _buildBalanceCard(
                iconPath: '',
                title: 'Total Balance',
                amount:'${totalBalance < 0 ? '-' : ''}\$${totalBalance.abs()}',
                amountColor:
                    totalBalance >= 0
                        ? AppColors.fenceGreen
                        : AppColors.oceanBlue,
                isSelected: currentListFilterType == null,
                savingAmount: saveAmount,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.read<TransactionBloc>().add(
                        const SelectFilterTypeEvent(MoneyType.income),
                      );
                    },
                    child: _buildBalanceCard(
                      iconPath: Assets.iconComponents.income.path,
                      title: 'Income',
                      amount: '\$$income',
                      amountColor: AppColors.caribbeanGreen,
                      isSelected: currentListFilterType == MoneyType.income,
                    ),
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.read<TransactionBloc>().add(
                        const SelectFilterTypeEvent(MoneyType.expense),
                      );
                    },
                    child: _buildBalanceCard(
                      iconPath: Assets.iconComponents.expense.path,
                      title: 'Expense',
                      amount: '\$$expense',
                      amountColor: AppColors.oceanBlue,
                      isSelected: currentListFilterType == MoneyType.expense,
                    ),
                  ),
                ),
                // _buildVerticalDivider(),
                // Expanded(
                //   child: GestureDetector(
                //     onTap: () {
                //       context.read<TransactionBloc>().add(
                //         const SelectFilterTypeEvent(MoneyType.save),
                //       );
                //     },
                //     child: _buildBalanceCard(
                //       iconPath: Assets.iconComponents.expense.path,
                //       title: 'Save',
                //       amount: '\$$expense',
                //       amountColor: AppColors.oceanBlue,
                //       isSelected: currentListFilterType == MoneyType.expense,
                //     ),
                //   ),
                // ),
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
      int? savingAmount,
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
                  colorFilter:
                      isSelected
                          ? const ColorFilter.mode(
                            AppColors.honeydew,
                            BlendMode.srcIn,
                          )
                          : ColorFilter.mode(amountColor, BlendMode.srcIn),
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
                    color:
                        isSelected ? AppColors.honeydew : AppColors.blackHeader,
                  ),
                ),
              ],
            ),
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
                    '(Save: \$${savingAmount.abs()})',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected
                              ? AppColors.honeydew.withValues(alpha: 0.8)
                              : AppColors.oceanBlue,
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

    Widget _buildMonthSelector(
      String selectedMonth,
      List<String> availableMonths,
    ) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Now: ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: AppFontWeight.thin,
                    color: AppColors.fenceGreen,
                  ),
                ),
                TextSpan(
                  text: selectedMonth,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.fenceGreen,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (month) {
              context.read<TransactionBloc>().add(SelectMonthEvent(month));
            },
            itemBuilder:
                (context) =>
                    availableMonths.map((month) {
                      return PopupMenuItem(
                        value: month,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 8.0,
                          ),
                          child: Text(
                            month,
                            style: TextStyle(
                              color:
                                  month == selectedMonth
                                      ? AppColors.caribbeanGreen
                                      : AppColors.fenceGreen,
                              fontWeight:
                                  month == selectedMonth
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 8,
            color: AppColors.honeydew,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.honeydew,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.fenceGreen.withValues(alpha: 0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    Assets.iconComponents.calender.path,
                    width: 25,
                    height: 25,
                  ),

                  const Icon(Icons.arrow_drop_down, color: AppColors.fenceGreen),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildTransactionSection(
      List<TransactionModel> transactions,
      String selectedMonth,
      List<String> availableMonths,
    ) {
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

      Map<String, List<TransactionModel>> groupedTransactions = {};
      for (var t in transactions) {
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

            final aMonthIndex = TransactionBloc.monthNames.indexOf(aParts[0]) + 1;
            final bMonthIndex = TransactionBloc.monthNames.indexOf(bParts[0]) + 1;
            final aDate = DateTime(int.parse(aParts[1]), aMonthIndex);
            final bDate = DateTime(int.parse(bParts[1]), bMonthIndex);
            return bDate.compareTo(aDate);
          });

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: _buildMonthSelector(selectedMonth, availableMonths),
          ),

          ...sortedMonthYears.map((monthYear) {
            final transactionsForMonth = groupedTransactions[monthYear]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                            date:
                                '${transaction.time.day.toString().padLeft(2, '0')} - ${transaction.time.hour.toString().padLeft(2, '0')}:${transaction.time.minute.toString().padLeft(2, '0')}',
                            label: transaction.idCategory.categoryType,
                            amount:
                                '${isIncome ? '' : '-'}${transaction.amount}',
                            backgroundColor:
                                isIncome
                                    ? AppColors.lightBlue
                                    : AppColors.vividBlue,
                            showDividers: true,
                          ),
                        );
                      })
                          .toList(),
                ),
              ],
            );
          }),
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
  }
