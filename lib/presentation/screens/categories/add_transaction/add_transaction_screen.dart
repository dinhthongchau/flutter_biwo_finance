import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


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
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = '6969';
    _titleController.text = '--Title Test--';
    _messageController.text = '--Message Test--';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onSaveTransaction(BuildContext context, AddTransactionState state) {
    if (_formKey.currentState!.validate() && state.selectedCategory != null) {
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
        state.selectedDate,
        int.parse(_amountController.text),
        state.selectedCategory!,
        _titleController.text,
        _messageController.text,
      );

      context.read<TransactionBloc>().add(AddTransactionEvent(newTransaction));
    } else if (state.selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
    }
  }

  void _transactionBlocListener(BuildContext context, TransactionState state) {
    if (state is TransactionSuccess) {
      _showSuccessNotification(context);
    } else if (state is TransactionError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Failed to add transaction.'),
        ),
      );
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

  void _showSuccessNotification(BuildContext context) {
    final bloc = context.read<AddTransactionBloc>();
    final state = bloc.state;
    final notificationModel = NotificationModel(
      iconPath: Assets.iconComponents.check.path,
      title: 'Transaction Added',
      subtitle:
      'Added ${_titleController.text} to ${state.selectedCategory!.categoryType}',
      time: DateFormat('HH:mm - MMMM dd').format(state.selectedDate),
      date: DateTime.now().toIso8601String(),
    );
    context.read<NotificationBloc>().add(AddNotification(notificationModel));
    DialogUtils.isSuccessDialog(context, 'Transaction added successfully!');
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddTransactionBloc(
        initialMoneyType: widget.initialSelectedCategory?.moneyType ?? widget.initialMoneyType ?? MoneyType.save,
        initialSelectedCategory: widget.initialSelectedCategory,
      )..add(LoadCategoriesEvent(initialSelectedCategory: widget.initialSelectedCategory)),
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: _transactionBlocListener,
        child: Scaffold(
          appBar: _buildAppBar(context),
          backgroundColor: AppColors.caribbeanGreen,
          body: _buildBody(context),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.caribbeanGreen,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.fenceGreen),
        onPressed: () => context.pop(),
      ),
      title: BlocBuilder<AddTransactionBloc, AddTransactionState>(
        builder: (context, state) => Text(
          _getScreenTitle(state.moneyType),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.fenceGreen,
          ),
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
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
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
              child: Form(key: _formKey, child: _buildFormFields(context)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return BlocBuilder<AddTransactionBloc, AddTransactionState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateField(context, state),
          const SizedBox(height: 20),
          _buildCategoryDropdown(context, state),
          const SizedBox(height: 20),
          _buildAmountField(),
          const SizedBox(height: 20),
          _buildTitleField(state),
          const SizedBox(height: 20),
          _buildMessageField(),
          const SizedBox(height: 40),
          _buildSaveButton(context, state),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, AddTransactionState state) {
    return _buildInputField(
      label: 'Date',
      readOnly: true,
      onTap: () => context.read<AddTransactionBloc>().add(SelectDateEvent(context)),
      controller: TextEditingController(
        text: DateFormat('MMMM dd,yyyy').format(state.selectedDate),
      ),
      suffixIcon: Icons.calendar_today,
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, AddTransactionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.caribbeanGreen.withValues(alpha: 0.5),
            ),
          ),
          child: DropdownButtonFormField<CategoryModel>(
            value: state.availableCategories.contains(state.selectedCategory) ? state.selectedCategory : null,
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            hint: const Text('Select the category'),
            items: state.availableCategories
                .map(
                  (category) => DropdownMenuItem(
                value: category,
                child: Text(category.categoryType),
              ),
            )
                .toList(),
            onChanged: state.availableCategories.isEmpty
                ? null
                : (CategoryModel? newValue) {
              context.read<AddTransactionBloc>().add(SelectCategoryEvent(newValue));
            },
            validator: (value) => value == null ? 'Please select a category' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return _buildInputField(
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
    );
  }

  Widget _buildTitleField(AddTransactionState state) {
    return _buildInputField(
      label: state.moneyType == MoneyType.expense
          ? 'Expense Title'
          : (state.moneyType == MoneyType.income
          ? 'Income Title'
          : 'Saving Title'),
      controller: _titleController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildMessageField() {
    return _buildInputField(
      label: 'Enter Message',
      controller: _messageController,
      maxLines: 4,
    );
  }

  Widget _buildSaveButton(BuildContext context, AddTransactionState state) {
    return Center(
      child: GestureDetector(
        onTap: () => _onSaveTransaction(context, state),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.caribbeanGreen,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.fenceGreen..withValues(alpha:0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Save',
            style: Theme.of(context).elevatedButtonTheme.style?.textStyle?.resolve({}) ??
                const TextStyle(color: AppColors.fenceGreen, fontSize: 15),
          ),
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
            suffixIcon: suffixIcon != null
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