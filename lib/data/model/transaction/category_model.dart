import 'package:finance_management/core/enum/enums.dart';

class CategoryModel {
  final int id;
  final MoneyType moneyType;
  final String categoryType;
  final int? goalSave; //goalSave for moneyType save  ( expense, income don't need )
  
  CategoryModel(this.id, this.moneyType, this.categoryType, {this.goalSave});
  
  // Convert MoneyType to String for Firestore
  String _moneyTypeToString(MoneyType type) {
    switch (type) {
      case MoneyType.expense:
        return 'expense';
      case MoneyType.income:
        return 'income';
      case MoneyType.save:
        return 'save';
    }
  }
  
  // Parse MoneyType from String
  static MoneyType _parseMoneyType(String type) {
    if (type == 'expense') return MoneyType.expense;
    if (type == 'income') return MoneyType.income;
    if (type == 'save') return MoneyType.save;
    throw Exception('Unknown MoneyType: $type');
  }
  
  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moneyType': _moneyTypeToString(moneyType),
      'categoryType': categoryType,
      'goalSave': goalSave,
    };
  }
  
  // Create CategoryModel from Firestore document
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      json['id'],
      _parseMoneyType(json['moneyType']),
      json['categoryType'],
      goalSave: json['goalSave'],
    );
  }
}

