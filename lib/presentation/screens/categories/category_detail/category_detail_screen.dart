import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CategoryDetailScreen extends StatelessWidget {
  static const String routeName = "/category-detail-screen";
  final CategoryModel category; 

  const CategoryDetailScreen({super.key, required this.category});

  String _getScreenTitle(CategoryModel category) {
    return '${category.categoryType} Transactions';
  }

  String _getExpenseIcon(String categoryType) {
    switch (categoryType) {
      case 'Groceries':
        return Assets.iconComponents.groceriesWhite.path;
      case 'Rent':
        return Assets.iconComponents.rentWhite.path;
      case 'Transport':
        return Assets.iconComponents.iconTransport.path;
      case 'Food':
        return Assets.iconComponents.groceriesWhite.path; 
      case 'Medicine':
        return Assets.iconComponents.iconMedicine.path;
      case 'Gifts':
        return Assets.iconComponents.iconGift.path;
      case 'Entertainment':
        return Assets.iconComponents.iconEntertainment.path;
      case 'Travel':
        return Assets.iconComponents.travel.path;
      case 'New House':
        return Assets.iconComponents.newHome.path; 
      case 'Wedding':
        return Assets.iconComponents.weddingDay.path; 
      case 'Salary':
        return Assets.iconComponents.salaryWhite.path;
      case 'Other Income':
        return Assets.iconComponents.income.path; 
      case 'Other Expense':
        return Assets.iconComponents.expense.path; 
      case 'Other Savings':
        return Assets.iconComponents.travel.path; 
      default:
        return Assets.iconComponents.expense.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
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
                color: AppColors.fenceGreen.withValues(alpha:0.2),
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
            style: Theme.of(context).elevatedButtonTheme.style?.textStyle?.resolve({}) ?? const TextStyle(color: AppColors.honeydew, fontSize: 15),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.caribbeanGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.fenceGreen),
          onPressed: () => Navigator.pop(context),
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
      ),
      backgroundColor: AppColors.caribbeanGreen, 
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          

          
          final filteredTransactions = state.allTransactions.where(
                (t) => t.idCategory.id == category.id, 
          ).toList();

          if (filteredTransactions.isEmpty) {
            return Center(
              child: Text(
                'No ${category.categoryType} transactions found.',
                style: const TextStyle(fontSize: 16, color: AppColors.blackHeader),
              ),
            );
          }

          
          final totalBalance = context.read<TransactionBloc>().calculateTotalBalance(state.allTransactions);

          
          final totalCategoryAmount = _calculateTotalCategoryAmount(filteredTransactions);

          
          Map<String, List<TransactionModel>> groupedTransactions = {};
          for (var t in filteredTransactions) {
            final monthYear = context.read<TransactionBloc>().getMonthName(t.time.month, t.time.year);
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), 
                child: Row(
                  children: [
                    Expanded(child: _buildTotalBalanceCard(totalBalance)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTotalCategoryAmountCard(totalCategoryAmount, category.moneyType)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
            color: AppColors.fenceGreen.withValues(alpha:0.1),
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
            '\$${totalBalance.abs()}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: totalBalance >= 0 ? AppColors.caribbeanGreen : AppColors.oceanBlue,
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
            color: AppColors.fenceGreen.withValues(alpha:0.1),
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
}