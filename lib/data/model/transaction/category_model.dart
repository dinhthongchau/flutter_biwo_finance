
import 'package:finance_management/core/enum/enums.dart';

class CategoryModel {
  final int id;
  final MoneyType moneyType;
  final String categoryType;
  final int? goalSave; //goalSave for moneyType save  ( expense, income don't need )
  CategoryModel(this.id, this.moneyType, this.categoryType,{this.goalSave});
}

