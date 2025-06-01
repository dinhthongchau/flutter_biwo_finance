import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class _AnalysisScreenState extends State<AnalysisScreen>
    with AnalysisScreenMixin {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AnalysisBloc, AnalysisState>(
      listener: (context, state) {
        if (state is AnalysisError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
          );
        }
        if (state is TransactionLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LoadingUtils.showLoading(context, true);
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LoadingUtils.showLoading(context, false);
          });
        }
      },
      builder: (context, state) {
        if (state is AnalysisLoading ||
            state.allTransactions == null ||
            state.allTransactions!.isEmpty) {
          return Scaffold(
            appBar: buildHeader(
              context,
              "Analysis",
              "/home-screen/notifications-screen",
            ),
            backgroundColor: AppColors.caribbeanGreen,
            body: Center(child: LoadingUtils.buildSpinKitSpinningLinesWhite()),
          );
        }

        final chartData = state.currentChartData ?? [];
        final double maxYValue =
            chartData.isEmpty
                ? 1000.0
                : chartData
                    .map((data) => [data.income, data.expense])
                    .expand((pair) => pair)
                    .reduce((a, b) => a > b ? a : b)
                    .toDouble();

        final double chartMaxY = (maxYValue * 1.2).ceilToDouble();

        final int totalIncome =
            chartData.isEmpty
                ? 0
                : chartData.map((data) => data.income).reduce((a, b) => a + b);
        final int totalExpense =
            chartData.isEmpty
                ? 0
                : chartData.map((data) => data.expense).reduce((a, b) => a + b);

        return Scaffold(
          appBar: buildHeader(
            context,
            "Analysis",
            "/home-screen/notifications-screen",
          ),
          backgroundColor: AppColors.caribbeanGreen,
          body: Container(
            padding: SharedLayout.getScreenPadding(context),// Mobile padding
            child: buildBody(
              state,
              chartData,
              chartMaxY,
              totalIncome,
              totalExpense,
            ),
          ),
        );
      },
    );
  }
}

// body: Container(
//         padding: MediaQuery.of(context).size.width > 600
//             ? const EdgeInsets.symmetric(horizontal: 100) // Web padding
//             : EdgeInsets.zero, // Mobile padding
//         child: buildBody(context),
//       ),
