import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
class TransactionRepository {
  final List<TransactionModel> transactionData = [];
  bool _isInitialized = false;

  Future<List<TransactionModel>> getTransactionsAPI() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (_isInitialized == false) {
        await generateMockData();
        _isInitialized = true;
      }

      return transactionData;
    } catch (e) {
      debugPrint('OrderDataService ERROR: Lỗi khi lấy dữ liệu mẫu: $e');
      return [];
    }
  }

  CategoryModel _getCategory(
    List<CategoryModel> categories,
    MoneyType type,
    String categoryName,
  ) {
    return categories.firstWhere(
      (c) => c.moneyType == type && c.categoryType == categoryName,
      orElse:
          () =>
              throw Exception(
                'Category not found: type=$type, name=$categoryName',
              ),
    );
  }

  Future<void> generateMockData() async {
    final now = DateTime.now();
    final user = UserModel(
      id: 1,
      fullName: "John Doe",
      email: "john@example.com",
      mobile: "1234567890",
      dob: "1990-01-01",
      password: "password123",
    );

    final categories = CategoryRepository.getAllCategories();

    DateTime startOfCurrentWeek = now.subtract(Duration(days: now.weekday - 1));

    DateTime startOfLastWeek = startOfCurrentWeek.subtract(
      const Duration(days: 7),
    );

    transactionData.add(
      TransactionModel(
        user,
        startOfLastWeek
            .add(const Duration(days: 1, hours: 10, minutes: 30))
            .millisecondsSinceEpoch,
        startOfLastWeek.add(const Duration(days: 1, hours: 10, minutes: 30)),
        50,
        _getCategory(categories, MoneyType.expense, "Food"),
        "Lunch last week",
        "Cafe",
      ),
    );

    transactionData.add(
      TransactionModel(
        user,
        startOfLastWeek
                .add(const Duration(days: 1, hours: 10, minutes: 30))
                .millisecondsSinceEpoch +
            1,
        startOfLastWeek.add(const Duration(days: 1, hours: 10, minutes: 30)),
        10000,
        _getCategory(categories, MoneyType.income, "Salary"),
        "Salary last week",
        "Salary",
      ),
    );

    transactionData.add(
      TransactionModel(
        user,
        startOfLastWeek
                .add(const Duration(days: 2, hours: 10, minutes: 30))
                .millisecondsSinceEpoch +
            2,
        startOfLastWeek.add(const Duration(days: 2, hours: 10, minutes: 30)),
        2000,
        _getCategory(categories, MoneyType.save, "New House"),
        "New House",
        "House",
      ),
    );

    for (int i = 15; i <= 50; i++) {
      final daysAgo = (i - 14) * 2;
      final isExpense = i % 3 == 0;
      final isSave = i % 5 == 0;
      final amount = (50 + i * 10) % 1000;
      final category =
          isExpense
              ? ["Food", "Transport", "Groceries", "Rent"][i % 4]
              : isSave
              ? ["Travel", "New House", "Wedding"][i % 3]
              : ["Salary", "Other Income"][i % 2];
      final title =
          isExpense
              ? ["Dinner", "Lunch", "Fuel", "Rent"][i % 4]
              : isSave
              ? ["Vacation", "Down payment", "Fund"][i % 3]
              : ["Monthly", "Bonus"][i % 2];

      final transactionDate = now.subtract(Duration(days: daysAgo));

      transactionData.add(
        TransactionModel(
          user,
          transactionDate.millisecondsSinceEpoch + i,
          transactionDate,
          amount,
          _getCategory(
            categories,
            isExpense
                ? MoneyType.expense
                : isSave
                ? MoneyType.save
                : MoneyType.income,
            category,
          ),
          title,
          "Mock transaction #$i",
        ),
      );
    }
  }

  Future<void> updateTransaction(TransactionModel updatedTransaction) async {
    final index = transactionData.indexWhere(
      (transaction) => transaction.id == updatedTransaction.id,
    );
    if (index != -1) {
      transactionData[index] = updatedTransaction;
      debugPrint(
        'Transaction updated in repository: ${updatedTransaction.title}',
      );
    } else {
      debugPrint(
        'Transaction with ID ${updatedTransaction.id} not found for update.',
      );
      throw Exception('Transaction with ID ${updatedTransaction.id} not found');
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    transactionData.add(transaction);

    debugPrint('Transaction added to repository: ${transaction.title}');
  }

  Future<void> deleteTransaction(int transactionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    transactionData.removeWhere(
      (transaction) => transaction.id == transactionId,
    );
    debugPrint('Transaction with ID $transactionId deleted from repository.');
  }
}
