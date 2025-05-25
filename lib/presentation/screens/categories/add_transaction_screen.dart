import 'package:finance_management/data/model/notification_model.dart';
import 'package:finance_management/presentation/bloc/notification/notification_bloc.dart';
import 'package:finance_management/presentation/bloc/notification/notification_event.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class AddTransactionScreen extends StatefulWidget {
  static const String routeName = "/add-transaction-screen";
  final MoneyType? initialMoneyType;
  final CategoryModel? initialSelectedCategory;

  const AddTransactionScreen({
    super.key,
    this.initialMoneyType,
    this.initialSelectedCategory,
  });

  @override
  AddTransactionScreenState createState() => AddTransactionScreenState();
}

class AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  CategoryModel? _selectedCategory;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  List<CategoryModel> _availableCategories = [];
  late MoneyType _currentMoneyType;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    _amountController.text = '2000';
    _titleController.text = 'Title Test';
    _messageController.text = 'Message Test';

    if (widget.initialSelectedCategory != null) {
      _currentMoneyType = widget.initialSelectedCategory!.moneyType;
    } else if (widget.initialMoneyType != null) {
      _currentMoneyType = widget.initialMoneyType!;
    } else {
      _currentMoneyType = MoneyType.save;
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await CategoryRepository().getCategoriesByMoneyType(
      _currentMoneyType,
    );
    setState(() {
      _availableCategories = categories;
      if (widget.initialSelectedCategory != null) {
        if (widget.initialSelectedCategory!.moneyType == _currentMoneyType) {
          _selectedCategory = _availableCategories.firstWhereOrNull(
            (cat) => cat.id == widget.initialSelectedCategory!.id,
          );
        } else {
          _selectedCategory = null;
        }
      } else {
        _selectedCategory = null;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.caribbeanGreen,
              onPrimary: AppColors.fenceGreen,
              onSurface: AppColors.blackHeader,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.caribbeanGreen,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onSaveTransaction() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category.')),
        );
        return;
      }

      final user = UserModel(
        id: 1,
        fullName: "John Doe",
        email: "john@example.com",
        mobile: "1234567890",
        dob: "1990-01-01",
        password: "password123",
      );

      final newTransaction = TransactionModel(
        user,
        DateTime.now().millisecondsSinceEpoch,
        _selectedDate,
        int.parse(_amountController.text),
        _selectedCategory!,
        _titleController.text,
        _messageController.text,
      );

      context.read<TransactionBloc>().add(AddTransactionEvent(newTransaction));

      context.pop();
    }
  }

  String _getScreenTitle(MoneyType type) {
    switch (type) {
      case MoneyType.income:
        return 'Add Income';
      case MoneyType.expense:
        return 'Add Expenses';
      case MoneyType.save:
        return 'Add Saving';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSuccess) {
          final notificationModel = NotificationModel(
            iconPath: Assets.iconComponents.check.path,
            title: 'Transaction Added',
            subtitle:
                'Added ${_titleController.text} to ${_selectedCategory!.categoryType}',
            time: DateFormat('HH:mm - MMMM dd').format(_selectedDate),
            date: DateTime.now().toIso8601String(),
          );
          context.read<NotificationBloc>().add(
            AddNotification(notificationModel),
          );
          DialogUtils.isSuccessDialog(
            context,
            'Transaction added successfully!',
          );
        } else if (state is TransactionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to add transaction.'),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.caribbeanGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.fenceGreen),
            onPressed: () => context.pop(),
          ),
          title: Text(
            _getScreenTitle(_currentMoneyType),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.fenceGreen,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: AppColors.fenceGreen,
              ),
              onPressed: () => context.push(NotificationScreen.routeName),
            ),
          ],
        ),
        backgroundColor: AppColors.caribbeanGreen,
        body: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.honeydew,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField(
                          label: 'Date',
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          controller: TextEditingController(
                            text: DateFormat(
                              'MMMM dd,yyyy',
                            ).format(_selectedDate),
                          ),
                          suffixIcon: Icons.calendar_today,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.blackHeader,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.caribbeanGreen.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          child: DropdownButtonFormField<CategoryModel>(
                            value: _selectedCategory,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            hint: const Text('Select the category'),
                            items:
                                _availableCategories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category.categoryType),
                                  );
                                }).toList(),
                            onChanged: (CategoryModel? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Please select a category'
                                        : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: 'Amount',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          prefixText: '\$',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label:
                              _currentMoneyType == MoneyType.expense
                                  ? 'Expense Title'
                                  : (_currentMoneyType == MoneyType.income
                                      ? 'Income Title'
                                      : 'Saving Title'),
                          controller: _titleController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: 'Enter Message',
                          controller: _messageController,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: GestureDetector(
                            onTap: _onSaveTransaction,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.caribbeanGreen,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.fenceGreen.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Save',
                                style:
                                    Theme.of(context)
                                        .elevatedButtonTheme
                                        .style
                                        ?.textStyle
                                        ?.resolve({}) ??
                                    const TextStyle(
                                      color: AppColors.fenceGreen,
                                      fontSize: 15,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.blackHeader,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightGreen,
            prefixText: prefixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.caribbeanGreen,
                width: 2,
              ),
            ),
            suffixIcon:
                suffixIcon != null
                    ? Icon(suffixIcon, color: AppColors.caribbeanGreen)
                    : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
