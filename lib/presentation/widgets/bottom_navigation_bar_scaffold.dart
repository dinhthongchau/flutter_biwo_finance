import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationBarScaffold extends StatelessWidget {
  const BottomNavigationBarScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index, BuildContext context) {
    // Only go to branch if it's not the current index or force navigation to the same tab
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );

    // Only reload transactions when explicitly navigating to the transaction tab (index 2)
    // or when returning to home tab (index 0) and it wasn't previously selected
    if (index == 2 && navigationShell.currentIndex != 2) {
      // Small delay to ensure the UI is updated first
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted) {
          context.read<TransactionBloc>().add(
            const LoadTransactionsEvent(month: "All"),
          );
        }
      });
    }
    if (index == 1) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if ( context.mounted) {
          context.read<AnalysisBloc>().add(const LoadAnalysisDataEvent());
        }

      });
      //context.read<AnalysisBloc>().add(const ChangeTimeFilterEvent(TimeFilterAnalysis.daily));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LoadingUtils.showLoading(context, true);
          });
        } else if (state is TransactionSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LoadingUtils.showLoading(context, false);
          });
        } else if (state is TransactionError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LoadingUtils.showLoading(context, false);
          });
          debugPrint("Error loading all transactions: ${state.errorMessage}");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Lỗi tải dữ liệu: ${state.errorMessage}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        color: AppColors.honeydew,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth >= 800;
            
            return Scaffold(
              extendBody: !isWeb,
              body: isWeb 
                ? _buildWebLayout(context)
                : navigationShell,
              bottomNavigationBar: isWeb 
                ? null 
                : _buildBottomNavigationBar(context),
            );
          }
        ),
      ),
    );
  }
  
  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        _buildLeftNavigationBar(context),
        Expanded(
          child: navigationShell,
        ),
      ],
    );
  }
  
  Widget _buildLeftNavigationBar(BuildContext context) {
    return Container(
      width: 100,
      decoration: const BoxDecoration(
        color: AppColors.lightGreen,
  
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Assets.bottomNavigationIcon.homeSvg.path, context),
            _buildNavItem(
              1,
              Assets.bottomNavigationIcon.analysisSvg.path,
              context,
            ),
            _buildNavItem(
              2,
              Assets.bottomNavigationIcon.transactions.path,
              context,
            ),
            _buildNavItem(
              3,
              Assets.bottomNavigationIcon.categorySvg.path,
              context,
            ),
            _buildNavItem(
              4,
              Assets.bottomNavigationIcon.profileSvg.path,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(70.0),
          topRight: Radius.circular(70.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          left: 25,
          right: 25,
          bottom: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Assets.bottomNavigationIcon.homeSvg.path, context),
            _buildNavItem(
              1,
              Assets.bottomNavigationIcon.analysisSvg.path,
              context,
            ),
            _buildNavItem(
              2,
              Assets.bottomNavigationIcon.transactions.path,
              context,
            ),
            _buildNavItem(
              3,
              Assets.bottomNavigationIcon.categorySvg.path,
              context,
            ),
            _buildNavItem(
              4,
              Assets.bottomNavigationIcon.profileSvg.path,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, BuildContext context) {
    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      child: Container(
        padding: const EdgeInsets.only(
          top: 10,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color:
              navigationShell.currentIndex == index
                  ? AppColors.caribbeanGreen
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: SvgPicture.asset(
          iconPath,
          width: index == 2 ? 27 : 22,
          height: 27,
        ),
      ),
    );
  }
}
