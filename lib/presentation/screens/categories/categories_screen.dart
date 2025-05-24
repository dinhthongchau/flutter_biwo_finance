
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class CategoriesScreen extends StatefulWidget {
  static const String routeName = "/categories-screen";
  final String categoriesScreenPath;
  const CategoriesScreen({super.key, required this.categoriesScreenPath});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.caribbeanGreen,
        elevation: 0,

        title: const Text(
          'Categories Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.fenceGreen,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.caribbeanGreen,
      body: Center(
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading && state.allTransactions.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                LoadingUtils.showLoading(context, true);
              });
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                LoadingUtils.showLoading(context, false);
              });
            }
            if (state is TransactionError && state.allTransactions.isEmpty) {
              return Center(
                child: Text(state.errorMessage ?? 'An unknown error occurred'),
              );
            }
            if (state.allTransactions.isEmpty) {
              return const Center(child: Text('No transactions available.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMoneyTypeCard(
                    context,
                    title: 'Income',
                    iconPath: Assets.iconComponents.income.path,
                    color: AppColors.caribbeanGreen,
                    moneyType: MoneyType.income,
                  ),
                  const SizedBox(height: 16),
                  _buildMoneyTypeCard(
                    context,
                    title: 'Expense',
                    iconPath: Assets.iconComponents.expense.path,
                    color: AppColors.oceanBlue,
                    moneyType: MoneyType.expense,
                  ),
                  const SizedBox(height: 16),
                  _buildMoneyTypeCard(
                    context,
                    title: 'Savings',
                    iconPath: Assets.iconComponents.vector7.path,

                    color: AppColors.lightBlue,

                    moneyType: MoneyType.save,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMoneyTypeCard(
    BuildContext context, {
    required String title,
    required String iconPath,
    required Color color,
    required MoneyType moneyType,
  }) {
    return GestureDetector(
      onTap: () {
        context.push(widget.categoriesScreenPath , extra: moneyType);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.honeydew,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 30,
                  height: 30,
                  colorFilter: const ColorFilter.mode(
                    AppColors.honeydew,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.blackHeader,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: AppColors.fenceGreen),
          ],
        ),
      ),
    );
  }
}
