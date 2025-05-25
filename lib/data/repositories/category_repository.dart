import 'package:finance_management/data/model/category_model.dart';

class CategoryRepository {
  static final List<CategoryModel> _allCategories = [
    CategoryModel(1, MoneyType.expense, "Food"),
    CategoryModel(2, MoneyType.expense, "Transport"),
    CategoryModel(3, MoneyType.expense, "Medicine"),
    CategoryModel(4, MoneyType.expense, "Groceries"),
    CategoryModel(5, MoneyType.expense, "Rent"),
    CategoryModel(6, MoneyType.expense, "Gifts"),
    CategoryModel(7, MoneyType.expense, "Entertainment"),
    CategoryModel(11, MoneyType.income, "Salary"),
    CategoryModel(12, MoneyType.income, "Other Income"),
    CategoryModel(8, MoneyType.save, "Travel", goalSave: 1000),
    CategoryModel(9, MoneyType.save, "New House", goalSave: 100000),
    CategoryModel(10, MoneyType.save, "Wedding", goalSave: 50000),
    CategoryModel(14, MoneyType.save, "Other Savings", goalSave: 500),
  ];

  static List<CategoryModel> getAllCategories() {
    return _allCategories;
  }

  Future<List<CategoryModel>> getCategoriesByMoneyType(MoneyType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allCategories.where((c) => c.moneyType == type).toList();
  }

  Future<void> addCategory(
    String name,
    MoneyType moneyType, {
    int? goalSave,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newId =
        _allCategories.isEmpty
            ? 1
            : _allCategories.map((c) => c.id).reduce((a, b) => a > b ? a : b) +
                1;
    _allCategories.add(
      CategoryModel(newId, moneyType, name, goalSave: goalSave),
    );
  }

  Future<void> updateCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _allCategories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _allCategories[index] = category;
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _allCategories.removeWhere((c) => c.id == categoryId);
  }
}
