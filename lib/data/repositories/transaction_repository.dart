import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/data/repositories/user_repository.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TransactionRepository {
  final Map<String, List<TransactionModel>> _userTransactions = {};
  final Set<String> _initializedUsers = {};
  String? _lastUserId;

  DateTime? _lastLoadTime;

  // Add a cache timeout (5 minutes)
  static const cacheDuration = Duration(minutes: 5);

  final bool _debugMode = true;
  static final TransactionRepository _instance =
      TransactionRepository._internal();
  factory TransactionRepository() => _instance;
  TransactionRepository._internal() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user?.uid != _lastUserId) {
        _log('User changed from $_lastUserId to ${user?.uid}');
        _lastUserId = user?.uid;
        if (user?.email != null) _loadDataForUser(user!.email!);
      }
    });
  }

  Future<void> _loadDataForUser(String email) async {
    try {
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) return;

      final user = await UserRepository().getUserById(authUser.uid);
      if (user == null) return;

      await CategoryRepository().initializeDefaultCategories();
      final categories = await CategoryRepository.getAllCategories();
      debugPrint(
        'All categories: ${categories.map((e) => '${e.categoryType} - ${e.moneyType}').toList()}',
      );
      final snapshot =
          await FirebaseFirestore.instance
              .collection('transactions')
              .doc('users')
              .collection(email)
              .doc('user_transactions')
              .collection('items')
              .get();

      final transactions = <TransactionModel>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final moneyType = _parseMoneyType(data['moneyType']);
        if (moneyType == null) continue;

        final category = categories.firstWhere(
          (c) =>
              c.moneyType == moneyType &&
              c.categoryType == data['categoryType'],
          orElse: () {
            debugPrint(
              '⚠️ Warning: Could not find category ${data['categoryType']} of type $moneyType',
            );
            // Tạo category tạm thời
            return CategoryModel(
              -1, // id đặc biệt
              moneyType,
              '[Deleted] ${data['categoryType']}',
            );
          },
        );

        transactions.add(
          TransactionModel(
            user,
            data['id'],
            DateTime.fromMillisecondsSinceEpoch(data['time']),
            data['amount'],
            category,
            data['title'],
            data['note'],
          ),
        );
      }

      if (transactions.isNotEmpty) {
        _userTransactions[email] = transactions;
        _initializedUsers.add(email);
      }
    } catch (e) {
      _log('Error loading data: $e');
    }
  }

  Future<void> _saveTransactionToFirestore(
    String email,
    TransactionModel transaction,
  ) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc('users')
        .collection(email)
        .doc('user_transactions')
        .collection('items')
        .doc(transaction.id.toString())
        .set({
          'id': transaction.id,
          'title': transaction.title,
          'amount': transaction.amount,
          'time': transaction.time.millisecondsSinceEpoch,
          'note': transaction.note,
          'categoryType': transaction.idCategory.categoryType,
          'moneyType': transaction.idCategory.moneyType.toString(),
        });
  }

  MoneyType? _parseMoneyType(String type) {
    if (type.contains('expense')) return MoneyType.expense;
    if (type.contains('income')) return MoneyType.income;
    if (type.contains('save')) return MoneyType.save;
    return null;
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final email = _getCurrentUserIdentifier();
    _userTransactions.putIfAbsent(email, () => []).add(transaction);
    await _saveTransactionToFirestore(email, transaction);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final email = _getCurrentUserIdentifier();
    final list = _userTransactions[email];
    if (list == null) return;
    final index = list.indexWhere((t) => t.id == transaction.id);
    if (index != -1) list[index] = transaction;
    await _saveTransactionToFirestore(email, transaction);
  }

  Future<void> deleteTransaction(int id) async {
    final email = _getCurrentUserIdentifier();
    _userTransactions[email]?.removeWhere((t) => t.id == id);
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc('users')
        .collection(email)
        .doc('user_transactions')
        .collection('items')
        .doc(id.toString())
        .delete();
  }

  Future<void> clearAllData() async {
    _log('Clearing all data');
    _userTransactions.clear();
    _initializedUsers.clear();
    final email = _getCurrentUserIdentifier();
    final snapshot =
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc('users')
            .collection(email)
            .doc('user_transactions')
            .collection('items')
            .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<TransactionModel>> getTransactionsAPI() async {
    final email = _getCurrentUserIdentifier();
    final now = DateTime.now();

    // Check if data is already loaded and cache is still valid
    final cacheIsValid =
        _lastLoadTime != null &&
        now.difference(_lastLoadTime!) < cacheDuration &&
        _initializedUsers.contains(email) &&
        _userTransactions.containsKey(email) &&
        _userTransactions[email]!.isNotEmpty;

    // Skip loading if cache is valid
    if (!cacheIsValid) {
      _log(
        '📊 TransactionRepo: Cache invalid or empty, loading transactions for $email',
      );
      await _loadDataForUser(email);
      _lastLoadTime = now;
    } else {
      _log(
        '📊 TransactionRepo: Using cached transactions for $email (count: ${_userTransactions[email]?.length ?? 0})',
      );
    }

    return _userTransactions[email] ?? [];
  }

  String _getCurrentUserIdentifier() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? 'guest_user';
  }

  void _log(String message) {
    if (_debugMode) debugPrint('📊 TransactionRepo: $message');
  }

  // CategoryModel _getCategory(
  //   List<CategoryModel> categories,
  //
  //   MoneyType type,
  //
  //   String categoryName,
  // ) {
  //   return categories.firstWhere(
  //     (c) => c.moneyType == type && c.categoryType == categoryName,
  //
  //     orElse:
  //         () =>
  //             throw Exception(
  //               'Category not found: type=$type, name=$categoryName',
  //             ),
  //   );
  // }

  // Future<void> generateMockData(String userEmail) async {
  //   final authUser = FirebaseAuth.instance.currentUser;
  //   if (authUser == null) {
  //     _log('No authenticated user found for email: $userEmail');
  //     throw Exception('User not logged in');
  //   }
  //
  //   final user = await UserRepository().getUserById(authUser.uid);
  //   if (user == null) {
  //     _log('User not found in database for ID: ${authUser.uid}');
  //     throw Exception('User not found in database');
  //   }
  //
  //   _log('Generating mock data for $userEmail');
  //   final List<TransactionModel> userTransactions = [];
  //   _userTransactions[userEmail] = userTransactions;
  //   final categories = CategoryRepository.getAllCategories();
  //   final random = Random();
  //
  //   // Hàm tạo giao dịch lương hàng tháng
  //   void addMonthlySalary(DateTime date, int salary) {
  //     final incomeCategories =
  //         categories.where((c) => c.moneyType == MoneyType.income).toList();
  //     final category =
  //         incomeCategories.isNotEmpty
  //             ? incomeCategories[random.nextInt(incomeCategories.length)]
  //             : categories.firstWhere((c) => c.moneyType == MoneyType.income);
  //
  //     final tx = TransactionModel(
  //       user,
  //       date.millisecondsSinceEpoch,
  //       date,
  //       salary,
  //       category,
  //       'Monthly Salary',
  //       'Salary for ${DateFormat('MMMM yyyy').format(date)}',
  //     );
  //     userTransactions.add(tx);
  //   }
  //
  //   // Hàm tạo giao dịch chi tiêu hoặc tiết kiệm
  //   void addTransaction(
  //     DateTime date,
  //     MoneyType moneyType,
  //     int amountRangeStart,
  //     int amountRangeEnd,
  //   ) {
  //     final availableCategories =
  //         categories.where((c) => c.moneyType == moneyType).toList();
  //     if (availableCategories.isEmpty) return;
  //
  //     final category =
  //         availableCategories[random.nextInt(availableCategories.length)];
  //     final time = DateTime(
  //       date.year,
  //       date.month,
  //       date.day,
  //       random.nextInt(24),
  //       random.nextInt(60),
  //     );
  //     final amount =
  //         amountRangeStart +
  //         random.nextInt(amountRangeEnd - amountRangeStart + 1);
  //
  //     final tx = TransactionModel(
  //       user,
  //       time.millisecondsSinceEpoch,
  //       time,
  //       amount,
  //       category,
  //       '${category.categoryType} on ${DateFormat('yyyy-MM-dd').format(time)}',
  //       'Auto-generated transaction #${userTransactions.length + 1}',
  //     );
  //     userTransactions.add(tx);
  //   }
  //
  //   // 2023: 35 giao dịch (1 lương/tháng + ~23 chi tiêu + ~11 tiết kiệm)
  //   for (int month = 1; month <= 12; month++) {
  //     // Thêm lương 300 USD vào ngày 1 mỗi tháng
  //     addMonthlySalary(DateTime(2023, month, 1), 300);
  //
  //     // Thêm ~23 chi tiêu (2-3 giao dịch/tháng, ngẫu nhiên)
  //     int transactions2023 = random.nextInt(3) + 2; // 2-4 giao dịch/tháng
  //     for (int i = 0; i < transactions2023; i++) {
  //       final day = random.nextInt(28) + 1; // Ngày ngẫu nhiên từ 1-28
  //       addTransaction(DateTime(2023, month, day), MoneyType.expense, 10, 100);
  //     }
  //
  //     // Thêm ~11 tiết kiệm (1 giao dịch/tháng cho 11 tháng)
  //     if (month <= 11) {
  //       final day = random.nextInt(28) + 1;
  //       addTransaction(DateTime(2023, month, day), MoneyType.save, 20, 50);
  //     }
  //   }
  //
  //   // 2024: 45 giao dịch (1 lương/tháng + ~33 chi tiêu + ~12 tiết kiệm)
  //   for (int month = 1; month <= 12; month++) {
  //     // Thêm lương 400 USD vào ngày 1 mỗi tháng
  //     addMonthlySalary(DateTime(2024, month, 1), 400);
  //
  //     // Thêm ~33 chi tiêu (2-4 giao dịch/tháng, ngẫu nhiên)
  //     int transactions2024 = random.nextInt(3) + 2; // 2-4 giao dịch/tháng
  //     for (int i = 0; i < transactions2024; i++) {
  //       final day = random.nextInt(28) + 1;
  //       addTransaction(DateTime(2024, month, day), MoneyType.expense, 10, 100);
  //     }
  //
  //     // Thêm ~12 tiết kiệm (1 giao dịch/tháng)
  //     final day = random.nextInt(28) + 1;
  //     addTransaction(DateTime(2024, month, day), MoneyType.save, 20, 50);
  //   }
  //
  //   // 2025: Từ đầu năm đến hiện tại (1-3 giao dịch/ngày + 1 lương/tháng)
  //   final now = DateTime.now();
  //   for (
  //     DateTime date = DateTime(2025, 1, 1);
  //     date.isBefore(now);
  //     date = date.add(const Duration(days: 1))
  //   ) {
  //     // Thêm lương 500 USD vào ngày 1 mỗi tháng
  //     if (date.day == 1) {
  //       addMonthlySalary(date, 500);
  //     }
  //
  //     // Thêm 1-3 giao dịch chi tiêu hoặc tiết kiệm mỗi ngày
  //     final transactionsPerDay = 1 + random.nextInt(3);
  //     for (int i = 0; i < transactionsPerDay; i++) {
  //       final moneyType =
  //           random.nextBool() ? MoneyType.expense : MoneyType.save;
  //       addTransaction(
  //         date,
  //         moneyType,
  //         moneyType == MoneyType.expense ? 10 : 20,
  //         moneyType == MoneyType.expense ? 100 : 50,
  //       );
  //     }
  //   }
  //
  //   _log(
  //     '✅ Generated ${userTransactions.length} transactions for $userEmail: ~35 for 2023, ~45 for 2024, daily for 2025',
  //   );
  // }
}
