import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  static const String routeName = "/categories-screen";
  final String categoriesScreenPath;
  const CategoriesScreen({super.key, required this.categoriesScreenPath});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>with CategoriesScreenMixin  {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarCategories(),
      backgroundColor: AppColors.caribbeanGreen,
      body: Container(
          padding: SharedLayout.getScreenPadding(context),
          child: buildBodyCategories()),
    );
  }
}
