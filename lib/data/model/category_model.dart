import 'package:finance_management/data/model/user_model.dart';

enum MoneyType { Expense, Income, Save }
class CategoryModel {
  final int id;
  final MoneyType moneyType;
  final String categoryType;

  CategoryModel(this.id, this.moneyType, this.categoryType);
}