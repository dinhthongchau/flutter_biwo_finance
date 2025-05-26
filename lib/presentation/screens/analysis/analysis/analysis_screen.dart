import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:finance_management/presentation/shared_data.dart';

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
  @override
  void initState() {
    super.initState();
    context.read<AnalysisBloc>().add(const LoadAnalysisDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AnalysisBloc, AnalysisState>(
      listener: (context, state) {
        if (state is AnalysisError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
          );
        }
      },
      builder: (context, state) {
        if (state is AnalysisLoading || state.allTransactions == null || state.allTransactions!.isEmpty) {
          return Scaffold(
            appBar: buildHeader(context, "Analysis", "/home-screen/notifications-screen"),
            backgroundColor: AppColors.caribbeanGreen,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final chartData = state.currentChartData ?? [];
        final double maxYValue = chartData.isEmpty
            ? 1000.0
            : chartData
            .map((data) => [data.income, data.expense])
            .expand((pair) => pair)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

        final double chartMaxY = (maxYValue * 1.2).ceilToDouble();

        final int totalIncome = chartData.isEmpty
            ? 0
            : chartData.map((data) => data.income).reduce((a, b) => a + b);
        final int totalExpense = chartData.isEmpty
            ? 0
            : chartData.map((data) => data.expense).reduce((a, b) => a + b);

        return Scaffold(
          appBar: buildHeader(context, "Analysis", "/home-screen/notifications-screen"),
          backgroundColor: AppColors.caribbeanGreen,
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 37),
                child: const Column(
                  children: [SizedBox(height: 10), SizedBox(height: 12)],
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
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTabsSection(state.selectedTimeFilter ?? TimeFilterAnalysis.daily),
                        _buildChartSection(chartData, chartMaxY),
                        _buildIncomeExpenseSection(totalIncome, totalExpense),
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

  Widget buildCards(int totalBalance, int totalExpense) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _buildBalanceCard(
              iconPath: 'assets/IconComponents/Income.svg',
              title: 'Total Balance',
              amount: '${totalBalance < 0 ? '-' : ''}\$${NumberFormat('#,###', 'en_US').format(totalBalance.abs())}',
              amountColor: totalBalance >= 0 ? AppColors.fenceGreen : AppColors.oceanBlue,
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
              amount: '\$${NumberFormat('#,###', 'en_US').format(totalExpense.abs())}',
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
                  GestureDetector(
                    onTap: () => context.push(widget.searchScreenPath),
                    child: SvgPicture.asset(
                      Assets.iconComponents.variant3.path,
                      width: 25,
                      height: 25,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => context.push(widget.calendarScreenPath),
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
            child: chartData.isEmpty || chartData.every((data) => data.income == 0 && data.expense == 0)
                ? const Center(
              child: Text(
                'No data available',
                style: TextStyle(color: AppColors.fenceGreen, fontSize: 16),
              ),
            )
                : SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: const CategoryAxis(
                labelStyle: TextStyle(color: AppColors.fenceGreen),
                majorTickLines: MajorTickLines(width: 0),
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(width: 1, color: AppColors.fenceGreen),
              ),
              primaryYAxis: NumericAxis(
                maximum: maxYValue,
                minimum: 0,
                interval: maxYValue > 0 ? maxYValue / 5 : 1000,
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(width: 0),
                majorGridLines: const MajorGridLines(
                  width: 1,
                  color: AppColors.lightBlue,
                  dashArray: [2, 2],
                ),
                labelStyle: const TextStyle(color: AppColors.lightBlue),
                numberFormat: NumberFormat.compactSimpleCurrency(locale: 'en_US', name: '\$'),
                axisLabelFormatter: (AxisLabelRenderDetails args) {
                  if (args.value == 0) {
                    return ChartAxisLabel('', args.textStyle);
                  }
                  return ChartAxisLabel(args.text, args.textStyle);
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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

  Widget _buildTabsSection(TimeFilterAnalysis selectedFilter) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton(
            title: 'Daily',
            isSelected: selectedFilter == TimeFilterAnalysis.daily,
            onTap: () => context.read<AnalysisBloc>().add(const ChangeTimeFilterEvent(TimeFilterAnalysis.daily)),
          ),
          _buildTabButton(
            title: 'Weekly',
            isSelected: selectedFilter == TimeFilterAnalysis.weekly,
            onTap: () => context.read<AnalysisBloc>().add(const ChangeTimeFilterEvent(TimeFilterAnalysis.weekly)),
          ),
          _buildTabButton(
            title: 'Monthly',
            isSelected: selectedFilter == TimeFilterAnalysis.monthly,
            onTap: () => context.read<AnalysisBloc>().add(const ChangeTimeFilterEvent(TimeFilterAnalysis.monthly)),
          ),
          _buildTabButton(
            title: 'Year',
            isSelected: selectedFilter == TimeFilterAnalysis.year,
            onTap: () => context.read<AnalysisBloc>().add(const ChangeTimeFilterEvent(TimeFilterAnalysis.year)),
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
          colorFilter: const ColorFilter.mode(AppColors.caribbeanGreen, BlendMode.srcIn),
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
          colorFilter: const ColorFilter.mode(AppColors.oceanBlue, BlendMode.srcIn),
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

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
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

  Widget _buildTargetsSection() {
    final categories = CategoryRepository.getAllCategories().where((c) => c.moneyType == MoneyType.save).toList();
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
            final transactions = context
                .read<AnalysisBloc>()
                .state
                .allTransactions
                ?.where((t) => t.idCategory.id == category.id)
                .toList() ?? [];
            final totalSaved = transactions.fold(0, (sum, t) => sum + t.amount);
            final progress = category.goalSave != null && category.goalSave! > 0
                ? (totalSaved / category.goalSave!).clamp(0.0, 1.0)
                : 0.0;
            final percentage = (progress * 100).round();
            return GestureDetector(
              onTap: () => context.push(CategoryDetailSaveScreen.routeName, extra: category),
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
}