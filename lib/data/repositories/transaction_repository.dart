import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/data/repositories/user_repository.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> updateCategoryAndTransactions(
    CategoryModel oldCategory,
    String newName,
  ) async {
    // 1. Update tên category trong Firestore
    await CategoryRepository().updateCategory(
      CategoryModel(
        oldCategory.id,
        oldCategory.moneyType,
        newName,
        goalSave: oldCategory.goalSave,
      ),
    );

    // 2. Update tất cả transaction có categoryType cũ
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    final transactionCollection = FirebaseFirestore.instance
        .collection('transactions')
        .doc('users')
        .collection(email)
        .doc('user_transactions')
        .collection('items');

    final snapshot =
        await transactionCollection
            .where('categoryType', isEqualTo: oldCategory.categoryType)
            .where('moneyType', isEqualTo: oldCategory.moneyType.toString())
            .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'categoryType': newName});
    }
  }
}
