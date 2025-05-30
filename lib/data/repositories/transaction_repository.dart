import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finance_management/data/repository/user/user_repository.dart';
import 'package:finance_management/presentation/shared_data.dart';

class TransactionRepository {
  final Map<String, List<TransactionModel>> _userTransactions = {};
  final Set<String> _initializedUsers = {};
  String? _lastUserId;
  String? _lastUserEmail;

  final bool _debugMode = true;
  static final TransactionRepository _instance = TransactionRepository._internal();
  factory TransactionRepository() => _instance;
  TransactionRepository._internal() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user?.uid != _lastUserId) {
        _log('User changed from $_lastUserId to ${user?.uid}');
        _lastUserId = user?.uid;
        _lastUserEmail = user?.email;
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

      final categories = CategoryRepository.getAllCategories();
      final snapshot = await FirebaseFirestore.instance
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
              (c) => c.moneyType == moneyType && c.categoryType == data['categoryType'],
          orElse: () => categories.first,
        );

        transactions.add(TransactionModel(
          user,
          data['id'],
          DateTime.fromMillisecondsSinceEpoch(data['time']),
          data['amount'],
          category,
          data['title'],
          data['note'],
        ));
      }

      if (transactions.isNotEmpty) {
        _userTransactions[email] = transactions;
        _initializedUsers.add(email);
      }
    } catch (e) {
      _log('Error loading data: $e');
    }
  }

  Future<void> _saveTransactionToFirestore(String email, TransactionModel transaction) async {
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
    final snapshot = await FirebaseFirestore.instance
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
    if (!_initializedUsers.contains(email)) {
      await _loadDataForUser(email);
      if (!_initializedUsers.contains(email)) {
        if (email == 'nkhiet3@gmail.com') {
          await generateMockData(email);
          _initializedUsers.add(email);
          for (var t in _userTransactions[email]!) {
            await _saveTransactionToFirestore(email, t);
          }
        } else {
          _initializedUsers.add(email);
          _userTransactions[email] = [];
        }
      }
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
  Future<void> generateMockData(String userEmail) async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      _log('No authenticated user found for email: $userEmail');
      throw Exception('User not logged in');
    }

    final user = await UserRepository().getUserById(authUser.uid);
    if (user == null) {
      _log('User not found in database for ID: ${authUser.uid}');
      throw Exception('User not found in database');
    }

    _log('Generating full mock data for $userEmail');
    final List<TransactionModel> userTransactions = [];
    _userTransactions[userEmail] = userTransactions;
    final categories = CategoryRepository.getAllCategories();

    final startDate = DateTime(2023, 1, 1); // Start from Jan 1, 2023
    final endDate = DateTime.now(); // Until today

    final random = Random();

    for (DateTime date = startDate;
    date.isBefore(endDate);
    date = date.add(const Duration(days: 1))) {
      final transactionsPerDay = 2 + random.nextInt(2); // 2-3 transactions/day

      for (int i = 0; i < transactionsPerDay; i++) {
        // Random time on that day
        final time = DateTime(
          date.year,
          date.month,
          date.day,
          random.nextInt(23),
          random.nextInt(59),
        );

        // Randomly assign transaction type
        final moneyType = MoneyType.values[random.nextInt(3)];

        // Get matching category
        final availableCategories = categories
            .where((c) => c.moneyType == moneyType)
            .toList();
        final category = availableCategories[random.nextInt(availableCategories.length)];

        final amount = 5000 + random.nextInt(15000); // Amount: 5k - 20k
        final title = '${category.categoryType} on ${date.toIso8601String().split("T")[0]}';
        final note = 'Auto-generated transaction #${userTransactions.length + 1}';

        final tx = TransactionModel(
          user,
          time.millisecondsSinceEpoch,
          time,
          amount as int,
          category,
          title,
          note,
        );

        userTransactions.add(tx);
      }
    }

    _log('✅ Generated ${userTransactions.length} transactions from Jan 2023 to now for $userEmail');
  }

}
