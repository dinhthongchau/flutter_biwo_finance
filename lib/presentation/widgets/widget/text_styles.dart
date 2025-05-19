import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:flutter/material.dart';
class AppFontWeight{
  static const FontWeight thin = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400; // Hoặc FontWeight.normal
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}
class AppTextStyles {
  static const TextStyle viduText = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.testColor,
    height: 1.2,
  );

}
