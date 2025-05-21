import 'package:finance_management/data/model/category_model.dart';
import 'package:finance_management/data/model/transaction_model.dart';
import 'package:finance_management/data/model/user_model.dart';
import 'package:flutter/material.dart';

class TransactionRepository {
  final List<TransactionModel> transactionData = [];

  Future<List<TransactionModel>> getTransactionsAPI() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      await generateMockData();
      return transactionData;
    } catch (e) {
      debugPrint('OrderDataService ERROR: Lỗi khi lấy dữ liệu mẫu: $e');
      return [];
    }
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

    // Define categories
    final categories = [
      CategoryModel(1, MoneyType.Expense, "Food"),
      CategoryModel(2, MoneyType.Expense, "Transport"),
      CategoryModel(3, MoneyType.Expense, "Medicine"),
      CategoryModel(4, MoneyType.Expense, "Groceries"),
      CategoryModel(5, MoneyType.Expense, "Rent"),
      CategoryModel(6, MoneyType.Expense, "Gifts"),
      CategoryModel(7, MoneyType.Expense, "Entertainment"),
      CategoryModel(8, MoneyType.Save, "Travel"),
      CategoryModel(9, MoneyType.Save, "New House"),
      CategoryModel(10, MoneyType.Save, "Wedding"),
      CategoryModel(11, MoneyType.Income, "Salary"),
      CategoryModel(12, MoneyType.Income, "Other"),
    ];

    transactionData.add(
      TransactionModel(
        user,
        1,
        now.subtract(Duration(days: 0)),
        70,
        categories.firstWhere((c) => c.categoryType == "Food"),
        "Test",
        "Test nhé",
      ),
    );
    transactionData.add(
      TransactionModel(
        user,
        1,
        now.subtract(Duration(days: 0)),
        100,
        categories.firstWhere((c) => c.categoryType == "Food"),
        "Test",
        "Test nhé",
      ),
    );
    // Additional Mock Data (up to 50)
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
              : ["Salary", "Other"][i % 2];
      final title =
          isExpense
              ? ["Dinner", "Lunch", "Fuel", "Rent"][i % 4]
              : isSave
              ? ["Vacation", "Down payment", "Fund"][i % 3]
              : ["Monthly", "Bonus"][i % 2];

      transactionData.add(
        TransactionModel(
          user,
          i,
          now.subtract(Duration(days: daysAgo)),
          amount,
          categories.firstWhere((c) => c.categoryType == category),
          title,
          "Mock transaction #$i",
        ),
      );
    }
  }
}
