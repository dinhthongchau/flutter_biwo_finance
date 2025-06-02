import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:finance_management/presentation/shared_data.dart';

mixin AnalysisScreenMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    context.read<AnalysisBloc>().add(const LoadAnalysisDataEvent());
  }
  Widget buildBody(AnalysisState state, List<BaseAnalysis> chartData, double chartMaxY, int totalIncome, int totalExpense) {
    return Column(
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
                  const SizedBox(height: 10),
                  _buildTabsSection(state.selectedTimeFilter ?? TimeFilterAnalysis.daily),
                  if (state.selectedTimeFilter == TimeFilterAnalysis.daily || state.selectedTimeFilter == TimeFilterAnalysis.weekly)
                    _buildDateRangeSelector(state),
                  _buildChartSection(chartData, chartMaxY),
                  _buildIncomeExpenseSection(totalIncome, totalExpense),
                  _buildTargetsSection(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector(AnalysisState state) {
    final startDate = state.startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final endDate = state.endDate ?? DateTime.now();
    
    // Check if can navigate forward
    bool canNavigateForward = true;
    if (state.selectedTimeFilter == TimeFilterAnalysis.daily) {
      canNavigateForward = !endDate.isAfter(DateTime.now().subtract(const Duration(days: 1)));
    } else if (state.selectedTimeFilter == TimeFilterAnalysis.weekly) {
      final currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
      canNavigateForward = !(startDate.year == currentMonth.year && startDate.month == currentMonth.month);
    }
    
    // We always allow navigating backward, but you can add restrictions if needed
    bool canNavigateBackward = true;
    
    String dateRangeText;
    if (state.selectedTimeFilter == TimeFilterAnalysis.daily) {
      dateRangeText = '${DateFormat('dd/MM').format(startDate)} - ${DateFormat('dd/MM').format(endDate)}';
    } else if (state.selectedTimeFilter == TimeFilterAnalysis.weekly) {
      // For weekly view, show the month name
      dateRangeText = DateFormat('MMMM yyyy').format(startDate);
    } else {
      // For monthly and yearly views
      dateRangeText = '${DateFormat('dd MMM').format(startDate)} - ${DateFormat('dd MMM').format(endDate)}';
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: canNavigateBackward ? () => _navigateDateRange(false, state) : null,
            child: Opacity(
              opacity: canNavigateBackward ? 1.0 : 0.5,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.caribbeanGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: AppColors.fenceGreen,
                  size: 24,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showDateRangePicker(state),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                dateRangeText,
                style: const TextStyle(
                  color: AppColors.fenceGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: canNavigateForward ? () => _navigateDateRange(true, state) : null,
            child: Opacity(
              opacity: canNavigateForward ? 1.0 : 0.5,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.caribbeanGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: AppColors.fenceGreen,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateDateRange(bool isForward, AnalysisState state) {
    final startDate = state.startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final endDate = state.endDate ?? DateTime.now();
    
    DateTime newStartDate;
    DateTime newEndDate;
    
    if (state.selectedTimeFilter == TimeFilterAnalysis.daily) {
      // For daily view, move by 7 days (a full week)
      if (isForward) {
        // Don't allow moving forward past today
        if (endDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))) return;
        
        newStartDate = startDate.add(const Duration(days: 7));
        newEndDate = endDate.add(const Duration(days: 7));
        
        // Don't go beyond today
        if (newEndDate.isAfter(DateTime.now())) {
          newEndDate = DateTime.now();
          // Find the Monday of the current week
          final currentWeekday = newEndDate.weekday;
          newStartDate = newEndDate.subtract(Duration(days: currentWeekday - 1));
        }
      } else {
        // Move back by 7 days
        newStartDate = startDate.subtract(const Duration(days: 7));
        newEndDate = endDate.subtract(const Duration(days: 7));
      }
    } else if (state.selectedTimeFilter == TimeFilterAnalysis.weekly) {
      // For weekly view, move by months
      if (isForward) {
        // Don't allow moving forward past current month
        final currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
        if (startDate.year == currentMonth.year && startDate.month == currentMonth.month) return;
        
        // Move to next month
        final nextMonth = startDate.month + 1;
        final nextMonthYear = startDate.year + (nextMonth > 12 ? 1 : 0);
        final nextMonthValue = nextMonth > 12 ? 1 : nextMonth;
        
        newStartDate = DateTime(nextMonthYear, nextMonthValue, 1);
        // Calculate last day of next month correctly
        final lastDay = DateTime(nextMonthYear, nextMonthValue + 1, 0).day;
        newEndDate = DateTime(nextMonthYear, nextMonthValue, lastDay, 23, 59, 59);
        
        // Don't go beyond current month
        final now = DateTime.now();
        if (newStartDate.year > now.year || 
            (newStartDate.year == now.year && newStartDate.month > now.month)) {
          newStartDate = DateTime(now.year, now.month, 1);
          final lastDayCurrentMonth = DateTime(now.year, now.month + 1, 0).day;
          newEndDate = DateTime(now.year, now.month, lastDayCurrentMonth, 23, 59, 59);
        }
      } else {
        // Move back by one month
        final prevMonth = startDate.month - 1;
        final prevMonthYear = startDate.year - (prevMonth < 1 ? 1 : 0);
        final prevMonthValue = prevMonth < 1 ? 12 : prevMonth;
        
        newStartDate = DateTime(prevMonthYear, prevMonthValue, 1);
        // Calculate last day of previous month correctly
        final lastDay = DateTime(prevMonthYear, prevMonthValue + 1, 0).day;
        newEndDate = DateTime(prevMonthYear, prevMonthValue, lastDay, 23, 59, 59);
      }
    } else {
      // For monthly and yearly views
      if (isForward) {
        final nextMonth = startDate.month + 1;
        final nextMonthYear = startDate.year + (nextMonth > 12 ? 1 : 0);
        final nextMonthValue = nextMonth > 12 ? 1 : nextMonth;
        
        newStartDate = DateTime(nextMonthYear, nextMonthValue, 1);
        final lastDay = DateTime(nextMonthYear, nextMonthValue + 1, 0).day;
        newEndDate = DateTime(nextMonthYear, nextMonthValue, lastDay, 23, 59, 59);
      } else {
        final prevMonth = startDate.month - 1;
        final prevMonthYear = startDate.year - (prevMonth < 1 ? 1 : 0);
        final prevMonthValue = prevMonth < 1 ? 12 : prevMonth;
        
        newStartDate = DateTime(prevMonthYear, prevMonthValue, 1);
        final lastDay = DateTime(prevMonthYear, prevMonthValue + 1, 0).day;
        newEndDate = DateTime(prevMonthYear, prevMonthValue, lastDay, 23, 59, 59);
      }
    }
    
    context.read<AnalysisBloc>().add(ChangeDateRangeEvent(
      startDate: newStartDate,
      endDate: newEndDate,
    ));
  }

  Future<void> _showDateRangePicker(AnalysisState state) async {
    if (state.selectedTimeFilter == TimeFilterAnalysis.weekly) {
      // For weekly view, show month picker instead
      final initialDate = state.startDate ?? DateTime.now();
      
      showMonthPicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      ).then((selectedDate) {
        if (selectedDate != null) {
          final startDate = DateTime(selectedDate.year, selectedDate.month, 1);
          // Calculate last day of month correctly
          final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
          final endDate = DateTime(selectedDate.year, selectedDate.month, lastDay, 23, 59, 59);
          
          context.read<AnalysisBloc>().add(ChangeDateRangeEvent(
            startDate: startDate,
            endDate: endDate,
          ));
        }
      });
      return;
    }
    
    final initialDateRange = DateTimeRange(
      start: state.startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: state.endDate ?? DateTime.now(),
    );
    
    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.caribbeanGreen,
              onPrimary: AppColors.fenceGreen,
              onSurface: AppColors.fenceGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDateRange != null) {
      context.read<AnalysisBloc>().add(ChangeDateRangeEvent(
        startDate: pickedDateRange.start,
        endDate: pickedDateRange.end,
      ));
    }
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
                    onTap: () => context.push((widget as AnalysisScreen).searchScreenPath),
                    child: SvgPicture.asset(
                      Assets.iconComponents.variant3.path,
                      width: 25,
                      height: 25,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => context.push((widget as AnalysisScreen).calendarScreenPath),
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
          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 2,
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

  Future<DateTime?> showMonthPicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: AppColors.honeydew,
          title: const Text(
            'Select Month',
            style: TextStyle(
              color: AppColors.fenceGreen,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildYearSelector(context, initialDate, firstDate, lastDate),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final date = DateTime(initialDate.year, month);
                      final isDisabled = date.isBefore(firstDate) || date.isAfter(lastDate);
                      final isSelected = date.year == initialDate.year && date.month == initialDate.month;
                      
                      return GestureDetector(
                        onTap: isDisabled ? null : () {
                          Navigator.pop(context, date);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.caribbeanGreen : AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? Border.all(color: AppColors.fenceGreen) : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            DateFormat('MMM').format(DateTime(2025, month)),
                            style: TextStyle(
                              color: isDisabled ? AppColors.lightGrey : AppColors.fenceGreen,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.fenceGreen),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildYearSelector(
    BuildContext context, 
    DateTime initialDate, 
    DateTime firstDate, 
    DateTime lastDate
  ) {
    final bool canNavigateBack = initialDate.year > firstDate.year;
    final bool canNavigateForward = initialDate.year < lastDate.year;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Opacity(
          opacity: canNavigateBack ? 1.0 : 0.5,
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.fenceGreen),
            onPressed: canNavigateBack ? () {
              final newDate = DateTime(initialDate.year - 1, initialDate.month);
              Navigator.pop(context);
              showMonthPicker(
                context: context,
                initialDate: newDate,
                firstDate: firstDate,
                lastDate: lastDate,
              ).then((date) {
                if (date != null) Navigator.pop(context, date);
              });
            } : null,
          ),
        ),
        Text(
          initialDate.year.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.fenceGreen,
          ),
        ),
        Opacity(
          opacity: canNavigateForward ? 1.0 : 0.5,
          child: IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.fenceGreen),
            onPressed: canNavigateForward ? () {
              final newDate = DateTime(initialDate.year + 1, initialDate.month);
              Navigator.pop(context);
              showMonthPicker(
                context: context,
                initialDate: newDate,
                firstDate: firstDate,
                lastDate: lastDate,
              ).then((date) {
                if (date != null) Navigator.pop(context, date);
              });
            } : null,
          ),
        ),
      ],
    );
  }
}