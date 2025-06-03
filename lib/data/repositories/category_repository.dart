import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CategoryRepository {
  // Default categories for new users or fallback
  static final List<CategoryModel> _defaultCategories = [
    CategoryModel(1, MoneyType.expense, "Food"),
    CategoryModel(2, MoneyType.expense, "Transport"),
    CategoryModel(3, MoneyType.expense, "Medicine"),
    CategoryModel(4, MoneyType.expense, "Groceries"),
    CategoryModel(5, MoneyType.expense, "Rent"),
    CategoryModel(6, MoneyType.expense, "Gifts"),
    CategoryModel(7, MoneyType.expense, "Entertainment"),
    CategoryModel(80, MoneyType.expense, "Other Expense"),
    CategoryModel(11, MoneyType.income, "Salary"),
    CategoryModel(12, MoneyType.income, "Other Income"),
    CategoryModel(8, MoneyType.save, "Travel", goalSave: 1000),
    CategoryModel(9, MoneyType.save, "New House", goalSave: 100000),
    CategoryModel(10, MoneyType.save, "Wedding", goalSave: 50000),
    CategoryModel(14, MoneyType.save, "Other Savings", goalSave: 500),
  ];

  // In-memory cache
  static List<CategoryModel> _cachedCategories = [];
  static bool _isInitialized = false;
  final bool _debugMode = true;

  // Singleton pattern
  static final CategoryRepository _instance = CategoryRepository._internal();
  factory CategoryRepository() => _instance;
  CategoryRepository._internal() {
    // Lắng nghe thay đổi trạng thái đăng nhập để xóa cache khi người dùng thay đổi
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _log('Auth state changed, clearing category cache');
      _cachedCategories = [];
      _isInitialized = false;
    });
  }

  // Lấy tất cả danh mục (luôn đảm bảo dữ liệu được tải từ Firebase)
  static List<CategoryModel> getAllCategories() {
    if (!_isInitialized) {
      // Nếu chưa khởi tạo, trả về danh sách mặc định
      // Khởi tạo sẽ được thực hiện bởi CategoryBloc khi app khởi động
      return _defaultCategories;
    }
    return _cachedCategories;
  }

  // Helper để lấy email người dùng hiện tại
  String _getCurrentUserIdentifier() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? 'guest_user';
  }

  // Debug logging
  void _log(String message) {
    if (_debugMode) debugPrint('🏷️ CategoryRepo: $message');
  }

  // Lấy tham chiếu collection Firestore cho categories
  CollectionReference _getCategoriesCollection() {
    final email = _getCurrentUserIdentifier();
    return FirebaseFirestore.instance
        .collection('categories')
        .doc('users')
        .collection(email);
  }

  // Khởi tạo danh mục mặc định cho người dùng mới
  Future<void> initializeDefaultCategories() async {
    final email = _getCurrentUserIdentifier();

    try {
      _log('Loading categories from Firestore for $email');
      final snapshot = await _getCategoriesCollection().get();

      if (snapshot.docs.isEmpty) {
        _log('No categories found, initializing default categories for $email');
        final batch = FirebaseFirestore.instance.batch();

        for (var category in _defaultCategories) {
          final docRef = _getCategoriesCollection().doc(category.id.toString());
          batch.set(docRef, {
            'id': category.id,
            'moneyType': _moneyTypeToString(category.moneyType),
            'categoryType': category.categoryType,
            'goalSave': category.goalSave,
          });
        }

        await batch.commit();
        _cachedCategories = List.from(_defaultCategories);
        _log('Default categories initialized successfully');
      } else {
        _log('Found ${snapshot.docs.length} categories for $email');
        final categories = <CategoryModel>[];
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          try {
            categories.add(
              CategoryModel(
                data['id'],
                _parseMoneyType(data['moneyType']),
                data['categoryType'],
                goalSave: data['goalSave'],
              ),
            );
          } catch (e) {
            _log('Error parsing category from Firestore: $e');
            // Skip invalid category
            continue;
          }
        }

        if (categories.isEmpty) {
          _log('No valid categories found, using defaults');
          _cachedCategories = List.from(_defaultCategories);
        } else {
          _cachedCategories = categories;
        }
      }

      _isInitialized = true;
      _log('Category initialization completed successfully');
    } catch (e) {
      _log('Error initializing categories: $e');
      // Use default categories as fallback
      _cachedCategories = List.from(_defaultCategories);
      _isInitialized = true;
    }
  }

  // Chuyển đổi MoneyType thành String
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

  // Phân tích MoneyType từ String
  MoneyType _parseMoneyType(String type) {
    if (type == 'expense') return MoneyType.expense;
    if (type == 'income') return MoneyType.income;
    if (type == 'save') return MoneyType.save;
    throw Exception('Unknown MoneyType: $type');
  }

  // Lấy danh mục theo loại tiền
  Future<List<CategoryModel>> getCategoriesByMoneyType(MoneyType type) async {
    if (!_isInitialized) {
      await initializeDefaultCategories();
    }
    return _cachedCategories.where((c) => c.moneyType == type).toList();
  }

  // Thêm danh mục mới
  Future<void> addCategory(
    String name,
    MoneyType moneyType, {
    int? goalSave,
  }) async {
    if (!_isInitialized) {
      await initializeDefaultCategories();
    }

    final newId =
        _cachedCategories.isEmpty
            ? 1
            : _cachedCategories
                    .map((c) => c.id)
                    .reduce((a, b) => a > b ? a : b) +
                1;

    final newCategory = CategoryModel(
      newId,
      moneyType,
      name,
      goalSave: goalSave,
    );

    try {
      // Thêm vào Firestore
      await _getCategoriesCollection().doc(newId.toString()).set({
        'id': newId,
        'moneyType': _moneyTypeToString(moneyType),
        'categoryType': name,
        'goalSave': goalSave,
      });

      // Cập nhật cache
      _cachedCategories.add(newCategory);
      _log('Added category: $name (id: $newId)');
    } catch (e) {
      _log('Error adding category: $e');
      throw Exception('Failed to add category: $e');
    }
  }

  // Cập nhật danh mục hiện có
  Future<void> updateCategory(CategoryModel category) async {
    try {
      // Cập nhật trong Firestore
      await _getCategoriesCollection().doc(category.id.toString()).update({
        'moneyType': _moneyTypeToString(category.moneyType),
        'categoryType': category.categoryType,
        'goalSave': category.goalSave,
      });

      // Cập nhật cache
      final index = _cachedCategories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _cachedCategories[index] = category;
      }
      _log('Updated category: ${category.categoryType} (id: ${category.id})');
    } catch (e) {
      _log('Error updating category: $e');
      throw Exception('Failed to update category: $e');
    }
  }

  // Xóa danh mục
  Future<void> deleteCategory(int categoryId) async {
    try {
      // Xóa từ Firestore
      await _getCategoriesCollection().doc(categoryId.toString()).delete();

      // Cập nhật cache
      _cachedCategories.removeWhere((c) => c.id == categoryId);
      _log('Deleted category id: $categoryId');
    } catch (e) {
      _log('Error deleting category: $e');
      throw Exception('Failed to delete category: $e');
    }
  }

  // Xóa cache để buộc tải lại
  void clearCache() {
    _cachedCategories = [];
    _isInitialized = false;
    _log('Category cache cleared');
  }
  // Thêm hàm getCategories để lấy danh mục từ Firestore hoặc cache
  Future<List<CategoryModel>> getCategories(String userId) async {
    if (!_isInitialized) {
      await initializeDefaultCategories(); // Khởi tạo danh mục nếu chưa có
    }
    _log('Returning ${ _cachedCategories.length} categories for user $userId');
    return List.from(_cachedCategories); // Trả về bản sao của cache
  }
}
