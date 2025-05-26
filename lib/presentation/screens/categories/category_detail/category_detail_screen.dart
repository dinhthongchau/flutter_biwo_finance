import 'package:finance_management/presentation/screens/categories/category_detail/categories_detail_screen_mixin.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';

class CategoryDetailScreen extends StatelessWidget with CategoriesDetailScreenMixin {
  static const String routeName = "/category-detail-screen";
  final CategoryModel category;

  const CategoryDetailScreen({super.key, required this.category});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: buildFloatingCategoryDetail(context, category),
      appBar: buildAppBarCategories(context, category),
      backgroundColor: AppColors.caribbeanGreen,
      body: buildBodyCategories(category),
    );
  }

}
