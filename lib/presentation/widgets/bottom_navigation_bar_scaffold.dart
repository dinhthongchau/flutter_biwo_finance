import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationBarScaffold extends StatelessWidget {
  const BottomNavigationBarScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.honeydew,
      child: Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
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
            _buildNavItem(0, Assets.bottomNavigationIcon.homeSvg.path),
            _buildNavItem(1, Assets.bottomNavigationIcon.analysisSvg.path),
            _buildNavItem(2, Assets.bottomNavigationIcon.transactions.path),
            _buildNavItem(3, Assets.bottomNavigationIcon.categorySvg.path),
            _buildNavItem(4, Assets.bottomNavigationIcon.profileSvg.path),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
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
