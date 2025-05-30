import 'package:finance_management/data/model/user/user_model.dart';
import 'package:finance_management/data/repository/user/user_repository.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TransactionRepository {
  // Use a map to store transactions for each user
  final Map<String, List<TransactionModel>> _userTransactions = {};
  final Set<String> _initializedUsers = {};
  String? _lastUserId;
  String? _lastUserEmail;

  // Debug flag
  final bool _debugMode = true;

  // Private constructor for singleton
  static final TransactionRepository _instance =
      TransactionRepository._internal();

  // Factory constructor
  factory TransactionRepository() {
    return _instance;
  }

  // Internal constructor
  TransactionRepository._internal() {
    // Load any saved data
    _loadSavedData();

    // Listen for auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user?.uid != _lastUserId) {
        _log('User changed from $_lastUserId to ${user?.uid}');

        // Save data for previous user if needed
        if (_lastUserEmail != null &&
            _userTransactions.containsKey(_lastUserEmail)) {
          _saveDataForUser(_lastUserEmail!);
        }

        _lastUserId = user?.uid;
        _lastUserEmail = user?.email;

        // Load data for new user if available
        if (user?.email != null) {
          _loadDataForUser(user!.email!);
        }
      }
    });
  }

  // Load all saved data on startup
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKeys = prefs.getStringList('transaction_users') ?? [];

      for (final email in userKeys) {
        await _loadDataForUser(email);
      }
      _log('Loaded data for ${userKeys.length} users from persistent storage');
    } catch (e) {
      _log('Error loading saved data: $e');
    }
  }

  // Load data for a specific user
  Future<void> _loadDataForUser(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('transactions_$email');

      if (jsonData != null) {
        final List<dynamic> decoded = jsonDecode(jsonData);
        _log(
          'Found saved data for user: $email (${decoded.length} transactions)',
        );

        // We need the user object and categories to reconstruct transactions
        final authUser = FirebaseAuth.instance.currentUser;
        if (authUser == null) {
          _log('Cannot load transactions: No authenticated user');
          return;
        }

        final user = await UserRepository().getUserById(authUser.uid);
        if (user == null) {
          _log('Cannot load transactions: User not found in database');
          return;
        }

        final categories = CategoryRepository.getAllCategories();
        final List<TransactionModel> transactions = [];

        for (final item in decoded) {
          try {
            // Find the matching category
            final moneyTypeStr = item['moneyType'] as String;
            final categoryType = item['categoryType'] as String;

            // Convert string moneyType back to enum
            MoneyType? moneyType;
            if (moneyTypeStr.contains('expense')) {
              moneyType = MoneyType.expense;
            } else if (moneyTypeStr.contains('income')) {
              moneyType = MoneyType.income;
            } else if (moneyTypeStr.contains('save')) {
              moneyType = MoneyType.save;
            }

            if (moneyType == null) {
              _log('Cannot parse money type: $moneyTypeStr');
              continue;
            }

            // Find the category
            final category = categories.firstWhere(
              (c) => c.moneyType == moneyType && c.categoryType == categoryType,
              orElse: () {
                _log('Category not found: $moneyType/$categoryType');
                return categories.first; // Fallback
              },
            );

            // Reconstruct the transaction
            final transaction = TransactionModel(
              user,
              item['id'] as int,
              DateTime.fromMillisecondsSinceEpoch(item['time'] as int),
              item['amount'] as int,
              category,
              item['title'] as String,
              item['note'] as String,
            );

            transactions.add(transaction);
          } catch (e) {
            _log('Error reconstructing transaction: $e');
          }
        }

        if (transactions.isNotEmpty) {
          _userTransactions[email] = transactions;
          _initializedUsers.add(email);
          _log(
            'Successfully loaded ${transactions.length} transactions for $email',
          );
        }
      }
    } catch (e) {
      _log('Error loading data for user $email: $e');
    }
  }

  // Save data for a specific user
  Future<void> _saveDataForUser(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _userTransactions[email];

      if (data != null) {
        // Save a simplified version since we can't fully serialize transaction models
        final simplified =
            data
                .map(
                  (t) => {
                    'id': t.id,
                    'title': t.title,
                    'amount': t.amount,
                    'time': t.time.millisecondsSinceEpoch,
                    'note': t.note,
                    'categoryType': t.idCategory.categoryType,
                    'moneyType': t.idCategory.moneyType.toString(),
                  },
                )
                .toList();

        final jsonData = jsonEncode(simplified);
        await prefs.setString('transactions_$email', jsonData);

        // Update the list of users with saved data
        final userKeys = prefs.getStringList('transaction_users') ?? [];
        if (!userKeys.contains(email)) {
          userKeys.add(email);
          await prefs.setStringList('transaction_users', userKeys);
        }

        _log('Saved transaction data for user: $email');
      }
    } catch (e) {
      _log('Error saving data for user $email: $e');
    }
  }

  // Clear cache for the current user only
  void clearUserCache(String email) {
    _log('Clearing cache for user: $email');
    _initializedUsers.remove(email);
    _userTransactions.remove(email);
  }

  // Clear all data for testing or logout
  Future<void> clearAllData() async {
    _log('Clearing all transaction data');
    _userTransactions.clear();
    _initializedUsers.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userKeys = prefs.getStringList('transaction_users') ?? [];

      for (final email in userKeys) {
        await prefs.remove('transactions_$email');
      }

      await prefs.remove('transaction_users');
      _log('Cleared all saved transaction data');
    } catch (e) {
      _log('Error clearing saved data: $e');
    }
  }

  // Log helper
  void _log(String message) {
    if (_debugMode) {
      debugPrint('📊 TransactionRepo: $message');
    }
  }

  // Get current user's email as identifier (more reliable than UID for testing)
  String _getCurrentUserIdentifier() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (email != null && email.isNotEmpty) {
      _log('Current user email: $email');
      return email;
    } else {
      _log('No user email found, using fallback ID');
      return 'guest_user';
    }
  }

  Future<List<TransactionModel>> getTransactionsAPI() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Get current user identifier
      final String userEmail = _getCurrentUserIdentifier();
      _log('Getting transactions for user: $userEmail');

      // Update last user info
      _lastUserEmail = userEmail;

      // Try to load data from storage first if not already initialized
      if (!_initializedUsers.contains(userEmail)) {
        // Check if we have saved data
        final prefs = await SharedPreferences.getInstance();
        final hasData = prefs.containsKey('transactions_$userEmail');

        if (hasData) {
          _log('Found saved data for user $userEmail - loading from storage');
          await _loadDataForUser(userEmail);
        }

        // If still not initialized (no saved data or failed to load), generate mock data
        if (!_initializedUsers.contains(userEmail)) {
          if (userEmail == 'nkhiet@gmail.com') {
            _log(
              'No saved data found for user $userEmail - generating mock data',
            );
            await generateMockData(userEmail);
            _initializedUsers.add(userEmail);
            // Save the newly generated data
            await _saveDataForUser(userEmail);
          }else {
            _log('No saved data found for user $userEmail - skipping mock data generation');
            _initializedUsers.add(userEmail);
            _userTransactions[userEmail] = []; // Initialize empty transaction list
          }



        }
      } else {
        _log('Using existing data for user $userEmail');
      }

      // Debug info about all users
      _log('All initialized users: ${_initializedUsers.toString()}');
      _log(
        'Transaction counts by user: ${_userTransactions.map((k, v) => MapEntry(k, v.length))}',
      );

      // Return the user's transactions or empty list if none
      return _userTransactions[userEmail] ?? [];
    } catch (e) {
      _log('ERROR: ${e.toString()}');
      throw Exception('Failed to load transactions: $e');
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

  Future<void> generateMockData(String userEmail) async {
    final now = DateTime.now();

    // Get user from repository using Firebase Auth UID
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

    _log('Generating mock data for: ${user.fullName} (${user.email})');

    // Create a new list for this user's transactions
    final List<TransactionModel> userTransactions = [];
    _userTransactions[userEmail] = userTransactions;

    final categories = CategoryRepository.getAllCategories();

    DateTime startOfCurrentWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime startOfLastWeek = startOfCurrentWeek.subtract(
      const Duration(days: 7),
    );

    // First transaction includes user email to easily distinguish users
    userTransactions.add(
      TransactionModel(
        user,
        startOfLastWeek
            .add(const Duration(days: 1, hours: 10, minutes: 30))
            .millisecondsSinceEpoch,
        startOfLastWeek.add(const Duration(days: 1, hours: 10, minutes: 30)),
        // Use a unique amount based on the email
        userEmail.hashCode.abs() % 1000 + 100,
        _getCategory(categories, MoneyType.expense, "Food"),
        "Initial transaction for ${userEmail}",
        "This is a unique transaction for ${userEmail}",
      ),
    );

    userTransactions.add(
      TransactionModel(
        user,
        startOfLastWeek
                .add(const Duration(days: 1, hours: 10, minutes: 30))
                .millisecondsSinceEpoch +
            1,
        startOfLastWeek.add(const Duration(days: 1, hours: 10, minutes: 30)),
        10000,
        _getCategory(categories, MoneyType.income, "Salary"),
        "Salary for ${userEmail}",
        "Monthly income",
      ),
    );

    userTransactions.add(
      TransactionModel(
        user,
        startOfLastWeek
                .add(const Duration(days: 2, hours: 10, minutes: 30))
                .millisecondsSinceEpoch +
            2,
        startOfLastWeek.add(const Duration(days: 2, hours: 10, minutes: 30)),
        2000,
        _getCategory(categories, MoneyType.save, "New House"),
        "Savings for ${userEmail}",
        "House fund",
      ),
    );

    // Generate only a few random transactions to make differences obvious
    for (int i = 1; i <= 5; i++) {
      final daysAgo = i * 2;
      final isExpense = i % 3 == 0;
      final isSave = i % 5 == 0;

      // Create a uniquely identifiable amount for this user
      final amount = userEmail.hashCode.abs() % 900 + 100 + (i * 10);

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

      userTransactions.add(
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
          "$title for ${userEmail}",
          "Transaction #$i specific to ${userEmail}",
        ),
      );
    }

    _log('Generated ${userTransactions.length} transactions for $userEmail');
  }

  Future<void> updateTransaction(TransactionModel updatedTransaction) async {
    final userEmail = _getCurrentUserIdentifier();
    final userTransactions = _userTransactions[userEmail] ?? [];

    _log('Updating transaction for user: $userEmail');

    final index = userTransactions.indexWhere(
      (transaction) => transaction.id == updatedTransaction.id,
    );
    if (index != -1) {
      userTransactions[index] = updatedTransaction;
      _log('Transaction updated: ${updatedTransaction.title}');

      // Save changes to persistent storage
      await _saveDataForUser(userEmail);
    } else {
      _log('Transaction not found for update: ${updatedTransaction.id}');
      throw Exception('Transaction with ID ${updatedTransaction.id} not found');
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final userEmail = _getCurrentUserIdentifier();

    _log('Adding transaction for user: $userEmail');

    // Initialize the list if it doesn't exist
    if (!_userTransactions.containsKey(userEmail)) {
      _userTransactions[userEmail] = [];
    }

    _userTransactions[userEmail]!.add(transaction);
    _log('Transaction added: ${transaction.title}');

    // Save changes to persistent storage
    await _saveDataForUser(userEmail);
  }

  Future<void> deleteTransaction(int transactionId) async {
    final userEmail = _getCurrentUserIdentifier();
    final userTransactions = _userTransactions[userEmail] ?? [];

    _log('Deleting transaction for user: $userEmail, ID: $transactionId');

    await Future.delayed(const Duration(milliseconds: 300));
    userTransactions.removeWhere(
      (transaction) => transaction.id == transactionId,
    );
    _log('Transaction deleted');

    // Save changes to persistent storage
    await _saveDataForUser(userEmail);
  }

  // Get the current transaction list for the user
  List<TransactionModel> get transactionData {
    final userEmail = _getCurrentUserIdentifier();
    return _userTransactions[userEmail] ?? [];
  }

  // Public method to save data for a user
  Future<void> saveDataForUser(String email) async {
    await _saveDataForUser(email);
  }
}
