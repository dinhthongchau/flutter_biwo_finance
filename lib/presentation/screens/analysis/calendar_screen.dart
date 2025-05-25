import 'package:finance_management/presentation/bloc/calendar/calendar_bloc.dart';
import 'package:finance_management/presentation/bloc/calendar/calendar_event.dart';
import 'package:finance_management/presentation/bloc/calendar/calendar_state.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class ChartSampleData {
  final String x;
  final double y;
  final Color color;

  ChartSampleData({required this.x, required this.y, required this.color});
}

enum ChartType { spends, categories }

class CalendarScreen extends StatelessWidget {
  static const String routeName = '/calendar-screen';

  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarBloc, CalendarState>(
      listener: (context, state) {
        if (state is CalendarError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Unknown error')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.caribbeanGreen,
          appBar: _buildHeader(context),
          body: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
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
                    child: state is CalendarLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.fenceGreen,
                        ),
                      ),
                    )
                        : SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        bottom: 20,
                        left: 20,
                        right: 20,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          _buildMonthYearSelector(context, state),
                          const SizedBox(height: 20),
                          _buildCalendar(context, state),
                          const SizedBox(height: 30),
                          _buildChartTypeSelector(context, state),
                          const SizedBox(height: 20),
                          if (state.selectedChartType == ChartType.categories &&
                              state.chartData.isNotEmpty)
                            Column(
                              children: [
                                _buildLegend(state),
                                const SizedBox(height: 20),
                              ],
                            ),
                          _buildSemiPieChart(context, state),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.fenceGreen,
                size: 20,
              ),
            ),
            const Text(
              'Calendar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.fenceGreen,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.honeydew,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month,
                color: AppColors.fenceGreen,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthYearSelector(BuildContext context, CalendarState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _changeMonth(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.caribbeanGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMMM').format(state.currentMonth),
                  style: const TextStyle(
                    color: AppColors.fenceGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.fenceGreen,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _changeYear(context, state),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.caribbeanGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.currentMonth.year.toString(),
                  style: const TextStyle(
                    color: AppColors.fenceGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.fenceGreen,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _changeMonth(BuildContext context) {
    showDialog(
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
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                return InkWell(
                  onTap: () {
                    context.read<CalendarBloc>().add(ChangeMonthEvent(month));
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Center(
                      child: Text(
                        DateFormat('MMMM').format(DateTime(2025, month)),
                        style: const TextStyle(
                          color: AppColors.fenceGreen,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.lightBlue),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _changeYear(BuildContext context, CalendarState state) {
    final yearsWithData = state.allTransactions
        ?.map((t) => t.time.year)
        .toSet()
        .toList() ?? [];
    if (yearsWithData.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 200,
            color: AppColors.honeydew,
            child: ListView.builder(
              itemCount: yearsWithData.length,
              itemBuilder: (context, index) {
                final year = yearsWithData[index];
                return ListTile(
                  title: Text(
                    year.toString(),
                    style: const TextStyle(color: AppColors.fenceGreen),
                  ),
                  onTap: () {
                    context.read<CalendarBloc>().add(ChangeYearEvent(year));
                    Navigator.pop(context);
                  },
                );
              },
            ),
          );
        },
      );
    }
  }

  Widget _buildCalendar(BuildContext context, CalendarState state) {
    final daysInMonth = DateTime(state.currentMonth.year, state.currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(state.currentMonth.year, state.currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.fenceGreen.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.caribbeanGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map(
                    (day) => Text(
                  day,
                  style: const TextStyle(
                    color: AppColors.caribbeanGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.read<CalendarBloc>().add(const ToggleAllMonthEvent()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: state.showAllMonth ? AppColors.caribbeanGreen : AppColors.honeydew,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.caribbeanGreen.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: state.showAllMonth
                        ? [
                      BoxShadow(
                        color: AppColors.caribbeanGreen.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.showAllMonth ? Icons.calendar_month : Icons.calendar_today,
                        color: state.showAllMonth ? AppColors.honeydew : AppColors.fenceGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'All Days',
                        style: TextStyle(
                          color: state.showAllMonth ? AppColors.honeydew : AppColors.fenceGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.caribbeanGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Has data',
                    style: TextStyle(color: AppColors.fenceGreen, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayIndex = index - (firstWeekday - 1);
              if (dayIndex < 1 || dayIndex > daysInMonth) {
                return Container();
              }

              final dayDate = DateTime(state.currentMonth.year, state.currentMonth.month, dayIndex);
              final isSelected = !state.showAllMonth &&
                  dayDate.day == state.selectedDate.day &&
                  dayDate.month == state.selectedDate.month &&
                  dayDate.year == state.selectedDate.year;
              final hasTransactions = state.allTransactions?.any(
                    (transaction) =>
                transaction.time.year == dayDate.year &&
                    transaction.time.month == dayDate.month &&
                    transaction.time.day == dayDate.day,
              ) ??
                  false;

              return GestureDetector(
                onTap: hasTransactions ? () => context.read<CalendarBloc>().add(SelectDateEvent(dayIndex)) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.caribbeanGreen
                        : hasTransactions
                        ? AppColors.honeydew
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: hasTransactions && !isSelected
                        ? Border.all(
                      color: AppColors.caribbeanGreen.withValues(alpha: 0.3),
                      width: 1,
                    )
                        : null,
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: AppColors.caribbeanGreen.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          dayIndex.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.honeydew
                                : hasTransactions
                                ? AppColors.fenceGreen
                                : AppColors.blackHeader.withValues(alpha: 0.4),
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : hasTransactions
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (hasTransactions && !isSelected)
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: 8,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.caribbeanGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector(BuildContext context, CalendarState state) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.read<CalendarBloc>().add(const ChangeChartTypeEvent(ChartType.spends)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: state.selectedChartType == ChartType.spends
                    ? AppColors.caribbeanGreen
                    : AppColors.lightGreen,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Text(
                  'Spends',
                  style: TextStyle(
                    color: AppColors.fenceGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: GestureDetector(
            onTap: () => context.read<CalendarBloc>().add(const ChangeChartTypeEvent(ChartType.categories)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: state.selectedChartType == ChartType.categories
                    ? AppColors.caribbeanGreen
                    : AppColors.lightGreen,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Text(
                  'Categories',
                  style: TextStyle(
                    color: AppColors.fenceGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSemiPieChart(BuildContext context, CalendarState state) {
    if (state.selectedChartType == ChartType.spends) {
      final selectedDateTransactions = state.allTransactions
          ?.where((t) => state.showAllMonth
          ? (t.time.year == state.currentMonth.year && t.time.month == state.currentMonth.month)
          : (t.time.year == state.selectedDate.year &&
          t.time.month == state.selectedDate.month &&
          t.time.day == state.selectedDate.day))
          .toList() ??
          [];

      if (selectedDateTransactions.isEmpty) {
        return const Center(
          child: Text(
            'No transactions for this period.',
            style: TextStyle(color: AppColors.fenceGreen, fontSize: 16),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: selectedDateTransactions.length,
        itemBuilder: (context, index) {
          final transaction = selectedDateTransactions[index];
          final isIncome = transaction.idCategory.moneyType == MoneyType.income;
          final isSave = transaction.idCategory.moneyType == MoneyType.save;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: buildTransactionItem(
              context: context,
              transactionId: transaction.id,
              title: transaction.title,
              iconPath: isIncome
                  ? Assets.iconComponents.salaryWhite.path
                  : isSave
                  ? Assets.iconComponents.vector7.path
                  : _getExpenseIcon(transaction.idCategory.categoryType),
              date: DateFormat('dd/MM/yy').format(transaction.time),
              label: transaction.idCategory.categoryType,
              amount: '${isIncome ? '' : '-'}${transaction.amount}',
              backgroundColor: isIncome
                  ? AppColors.lightBlue
                  : isSave
                  ? AppColors.caribbeanGreen
                  : AppColors.vividBlue,
              showDividers: true,
            ),
          );
        },
      );
    }

    if (state.chartData.isEmpty) {
      return const Center(
        child: Text(
          'No data available for this period.',
          style: TextStyle(color: AppColors.fenceGreen, fontSize: 16),
        ),
      );
    }

    return Container(
      height: 300,
      color: AppColors.honeydew,
      child: SfCircularChart(
        series: <PieSeries<ChartSampleData, String>>[
          PieSeries<ChartSampleData, String>(
            dataSource: state.chartData,
            xValueMapper: (ChartSampleData data, _) => data.x,
            yValueMapper: (ChartSampleData data, _) => data.y,
            pointColorMapper: (ChartSampleData data, _) => data.color,
            startAngle: 270,
            endAngle: 90,
            radius: '70%',
            explode: true,
            explodeOffset: '10%',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.fenceGreen,
              ),
            ),
            dataLabelMapper: (ChartSampleData data, _) => '${data.y.toStringAsFixed(1)}%',
          ),
        ],
      ),
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

  Widget _buildLegend(CalendarState state) {
    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: state.chartData.map((data) {
            return Container(
              margin: const EdgeInsets.only(right: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: data.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    data.x,
                    style: const TextStyle(
                      color: AppColors.fenceGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}