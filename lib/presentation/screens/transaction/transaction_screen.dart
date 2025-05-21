import 'package:finance_management/gen/assets.gen.dart';
import 'package:finance_management/presentation/routes.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TransactionScreen extends StatelessWidget {
  static const String routeName = "/transaction-screen";

  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildHeader(context),
      body: const Text("hello Transaction"),
    );
  }
}

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
