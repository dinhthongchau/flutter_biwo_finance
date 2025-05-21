import 'package:finance_management/gen/assets.gen.dart';
import 'package:finance_management/presentation/routes.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home-screen';
  final String label;
  final String detailsPath;

  const HomeScreen({super.key, required this.label, required this.detailsPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildHeader(context),
      backgroundColor: AppColors.caribbeanGreen,
      body: SingleChildScrollView(
        child: Column(children: [_buildBody(context)]),
      ),
    );
  }

  // Header Section
  PreferredSizeWidget _buildHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 25),
      child: Padding(
        padding: const EdgeInsets.only(left: 37, right: 36, top: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildWelcomeText(), _buildNotificationButton(context)],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, Welcome Back',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.fenceGreen,
          ),
        ),
        Text(
          'Good Morning',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.fenceGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context
            .findAncestorStateOfType<BottomNavigationBarScaffoldState>()
            ?.goToNotifications();
        // context.go(NotificationScreen.routeName);
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
    );
  }

  // Body Section
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
              _buildProgressFeedbackSection(),
              const SizedBox(height: 32),
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
            children: [
              const SizedBox(height: 33),
              _buildSavingsRevenueSection(),
              const SizedBox(height: 26),
              _buildTabsSection(),
              const SizedBox(height: 24),
              _buildTransactionSection(context),
            ],
          ),
        ),
      ],
    );
  }

  // Balance and Expense Section
  Widget _buildBalanceExpenseSection() {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _buildBalanceCard(
              iconPath: 'assets/IconComponents/Income.svg',
              title: 'Total Balance',
              amount: '\$7,783.00',
              amountColor: AppColors.honeydew,
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildBalanceCard(
              iconPath: 'assets/IconComponents/Expense.svg',
              title: 'Total Expense',
              amount: '-\$1,187.40',
              amountColor: AppColors.oceanBlue,
            ),
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
  }) {
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
        Text(
          amount,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 36),
      color: AppColors.lightGreen,
    );
  }

  // Progress Feedback Section
  Widget _buildProgressFeedbackSection() {
    return Column(
      children: [
        _buildProgressIndicator(percentage: 30, amount: '\$20,000.00'),
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
          '30% Of Your Expenses, Looks Good.',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.fenceGreen,
          ),
        ),
      ],
    );
  }

  // Savings and Revenue Sectionq
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
    return Container(
      height: 115,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.honeydew, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedCircularProgress(),
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
            'On Goals',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.blackHeader,
            ),
          ),
        ],
      ),
    );
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRevenueItem(
          iconPath: 'assets/IconComponents/Vector-1.svg',
          title: 'Revenue Last Week',
          amount: '\$4,000.00',
          amountColor: AppColors.fenceGreen,
          showDivider: true,
        ),
        _buildRevenueItem(
          iconPath: 'assets/IconComponents/Salary.svg',
          title: 'Food Last Week',
          amount: '-\$100.00',
          amountColor: AppColors.oceanBlue,
          showDivider: false,
        ),
      ],
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

  // Tabs Section
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
          _buildTab('Daily', false),
          _buildTab('Weekly', false),
          _buildTab('Monthly', true),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return Container(
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
    );
  }

  // Transaction Section
  Widget _buildTransactionSection(BuildContext context) {
    final transactions = [
      {
        'title': 'Salary',
        'iconPath': 'assets/IconComponents/salary-white.svg',
        'date': '18:27 - April 30',
        'label': 'Monthly',
        'amount': '\$4,000.00',
        'backgroundColor': AppColors.lightBlue,
      },
      {
        'title': 'Groceries',
        'iconPath': 'assets/IconComponents/groceries-white.svg',
        'date': '17:00 - April 24',
        'label': 'Pantry',
        'amount': '-\$100.00',
        'backgroundColor': AppColors.vividBlue,
      },
      {
        'title': 'Rent',
        'iconPath': 'assets/IconComponents/rent-white.svg',
        'date': '8:30 - April 15',
        'label': 'Rent',
        'amount': '-\$674.40',
        'backgroundColor': AppColors.oceanBlue,
      },
    ];

    return Column(
      children:
          transactions
              .map(
                (transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTransactionItem(
                    title: transaction['title'] as String,
                    iconPath: transaction['iconPath'] as String,
                    date: transaction['date'] as String,
                    label: transaction['label'] as String,
                    amount: transaction['amount'] as String,
                    backgroundColor: transaction['backgroundColor'] as Color,
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String iconPath,
    required String date,
    required String label,
    required String amount,
    required Color backgroundColor,
  }) {
    return Row(
      children: [
        _buildTransactionIcon(
          iconPath: iconPath,
          backgroundColor: backgroundColor,
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildTransactionDetails(title: title, date: date)),
        _buildTransactionDivider(),
        Expanded(child: _buildTransactionLabel(label: label)),
        _buildTransactionDivider(),
        Expanded(child: _buildTransactionAmount(amount: amount)),
      ],
    );
  }

  Widget _buildTransactionIcon({
    required String iconPath,
    required Color backgroundColor,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTransactionDetails({
    required String title,
    required String date,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.fenceGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.oceanBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionLabel({required String label}) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.fenceGreen,
      ),
    );
  }

  Widget _buildTransactionAmount({required String amount}) {
    return Center(
      child: Text(
        amount,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color:
              amount.startsWith('-')
                  ? AppColors.oceanBlue
                  : AppColors.fenceGreen,
        ),
      ),
    );
  }

  Widget _buildTransactionDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.caribbeanGreen.withValues(alpha: 0.3),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
