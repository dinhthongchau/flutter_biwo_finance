import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';

class CategoryListScreen extends StatefulWidget {
  static const String routeName = "/category-list-screen";
  final MoneyType moneyType;

  const CategoryListScreen({super.key, required this.moneyType});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen>  with CategoryListScreenMixin{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildFloatingCategoryList(context),
      appBar: buildAppBarCategoryList(context),
      backgroundColor: AppColors.caribbeanGreen,
      body: Container(padding: SharedLayout.getScreenPadding(context),child: buildBodyListScreen()),
    );
  }

}
