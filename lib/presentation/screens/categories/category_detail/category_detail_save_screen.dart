import 'package:finance_management/presentation/screens/categories/category_detail/categories_detail_screen_mixin.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';

class CategoryDetailSaveScreen extends StatelessWidget with CategoriesDetailScreenMixin{
  static const String routeName = "/category-detail-save-screen";
  final CategoryModel category;

  const CategoryDetailSaveScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: buildFloatingCategorySave(context, category),
      appBar: buildAppBarSave(context, category),
      backgroundColor: AppColors.caribbeanGreen,
      body: buildBodySave(category),
    );
  }

}
