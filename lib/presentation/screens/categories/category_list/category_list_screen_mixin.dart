import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

mixin CategoryListScreenMixin<T extends StatefulWidget> on State<T>  {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories((widget as CategoryListScreen).moneyType));
  }



  AppBar buildAppBarCategoryList(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.caribbeanGreen,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.fenceGreen),
        onPressed: () => context.pop(),
      ),
      title: Text(
        _getScreenTitle((widget as CategoryListScreen).moneyType),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.fenceGreen,
        ),
      ),
      centerTitle: true,
    );
  }

  String _getScreenTitle(MoneyType type) {
    switch (type) {
      case MoneyType.income:
        return 'Income Categories';
      case MoneyType.expense:
        return 'Expense Categories';
      case MoneyType.save:
        return 'Savings Categories';
    }
  }

  Color _getCategoryColor(MoneyType moneyType) {
    switch (moneyType) {
      case MoneyType.income:
        return AppColors.caribbeanGreen;
      case MoneyType.expense:
        return AppColors.oceanBlue;
      case MoneyType.save:
        return AppColors.lightBlue;
    }
  }

  Container buildFloatingCategoryList(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 80.0, left: 150),
      child: GestureDetector(
        onTap: () {
          context.push(AddTransactionScreen.routeName, extra: (widget as CategoryListScreen).moneyType);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.caribbeanGreen,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.fenceGreen.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            (widget as CategoryListScreen).moneyType == MoneyType.expense
                ? 'Add Transaction Expense'
                : (widget as CategoryListScreen).moneyType == MoneyType.income
                ? 'Add Transaction Income'
                : 'Add Transaction Saving',
            style:
            Theme.of(
              context,
            ).elevatedButtonTheme.style?.textStyle?.resolve({}) ??
                const TextStyle(color: AppColors.honeydew, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget buildBodyListScreen() {
    final transactionBloc = context.watch<TransactionBloc>();
    final totalBalance = transactionBloc.calculateTotalBalance(
      transactionBloc.state.allTransactions,
    );
    final totalMoneyType =
    transactionBloc.calculateFinancialsForMoneyType(
      transactionBloc.state.allTransactions,
      (widget as CategoryListScreen).moneyType,
    )['totalAmount']!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(child: _buildTotalBalanceCard(totalBalance)),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTotalMoneyTypeCard(
                  totalMoneyType,
                  (widget as CategoryListScreen).moneyType,
                ),
              ),
            ],
          ),
        ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: BlocConsumer<CategoryBloc, CategoryState>(
                listener: (context, state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (state is CategoryLoading) {
                      LoadingUtils.showLoading(context, true);
                    } else {
                      LoadingUtils.showLoading(context, false);
                    }
                    if (state is CategoryError) {
                      debugPrint(
                        "Error loading categories: ${state.errorMessage}",
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Lỗi tải dữ liệu: ${state.errorMessage}",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  });
                },
                builder: (context, state) {
                  if (state is CategoryError) {
                    return Center(
                      child: Text(
                        'Error loading categories: ${state.errorMessage}',
                      ),
                    );
                  }
                  if (state is CategorySuccess && state.categories.isEmpty) {
                    return Center(
                      child: Text(
                        'No ${(widget as CategoryListScreen).moneyType.toString().split('.').last} categories defined.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.fenceGreen,
                        ),
                      ),
                    );
                  }

                  final categoriesOfType =
                  state is CategorySuccess ? state.categories : [];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                       SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 6 : 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: categoriesOfType.length + 1,
                      itemBuilder: (context, index) {
                        if (index < categoriesOfType.length) {
                          final category = categoriesOfType[index];
                          return _buildCategoryGridItem(
                            context,
                            category: category,
                            iconPath: CategoryIconUtils.getCategoriesIconPath(
                              category.categoryType,
                              category.moneyType,
                            ),
                            color: _getCategoryColor(category.moneyType),
                          );
                        } else {
                          return _buildMoreCategoryGridItem(
                            context,
                            (widget as CategoryListScreen).moneyType,
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBalanceCard(int totalBalance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.honeydew,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.fenceGreen.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.fenceGreen,
            ),
          ),
          Text(
            '${totalBalance < 0 ? '-' : ''}\$${totalBalance.abs()}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:
              totalBalance >= 0
                  ? AppColors.caribbeanGreen
                  : AppColors.oceanBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalMoneyTypeCard(int totalMoneyType, MoneyType type) {
    String moneyTypeTitle;
    Color moneyTypeColor;

    switch (type) {
      case MoneyType.income:
        moneyTypeTitle = 'Total Income';
        moneyTypeColor = AppColors.caribbeanGreen;
        break;
      case MoneyType.expense:
        moneyTypeTitle = 'Total Expenses';
        moneyTypeColor = AppColors.oceanBlue;
        break;
      case MoneyType.save:
        moneyTypeTitle = 'Total Savings';
        moneyTypeColor = AppColors.lightBlue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.honeydew,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.fenceGreen.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            moneyTypeTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.fenceGreen,
            ),
          ),
          Text(
            '\$${totalMoneyType.abs()}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: moneyTypeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGridItem(
      BuildContext context, {
        required CategoryModel category,
        required String iconPath,
        required Color color,
      }) {
    final hasTransactions = context
        .read<TransactionBloc>()
        .state
        .allTransactions
        .any((t) => t.idCategory.id == category.id);

    return GestureDetector(
      onTap:
      hasTransactions
          ? () {
        if (category.moneyType == MoneyType.save) {
          context.push(
            CategoryDetailSaveScreen.routeName,
            extra: category,
          );
        } else {
          context.push(CategoryDetailScreen.routeName, extra: category);
        }
      }
          : null,
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) {
            String? updatedName = category.categoryType;
            String? updatedGoalSave = category.goalSave?.toString();

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Edit Category',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (value) => updatedName = value,
                        decoration: const InputDecoration(
                          hintText: 'Category Name',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppColors.caribbeanGreen),
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        style: const TextStyle(color: AppColors.fenceGreen),
                        controller: TextEditingController(
                          text: category.categoryType,
                        ),
                      ),
                    ),
                    if (category.moneyType == MoneyType.save) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          onChanged: (value) => updatedGoalSave = value,
                          decoration: const InputDecoration(
                            hintText: 'Goal Save Amount',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: AppColors.caribbeanGreen,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          style: const TextStyle(color: AppColors.fenceGreen),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                            text: category.goalSave?.toString(),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        if (updatedName != null && updatedName!.isNotEmpty) {
                          final categories =
                          CategoryRepository.getAllCategories();
                          if (categories.any(
                                (c) =>
                            c.categoryType.toLowerCase() ==
                                updatedName!.toLowerCase() &&
                                c.moneyType == category.moneyType &&
                                c.id != category.id,
                          )) {
                            SnackbarUtils.showNoticeSnackbar(
                              context,
                              'Category already exists',
                              true,
                            );
                            return;
                          }
                          if (category.moneyType == MoneyType.save &&
                              (updatedGoalSave == null ||
                                  updatedGoalSave!.isEmpty)) {
                            SnackbarUtils.showNoticeSnackbar(
                              context,
                              'Goal Save is required',
                              true,
                            );
                            return;
                          }
                          final updatedCategory = CategoryModel(
                            category.id,
                            category.moneyType,
                            updatedName!,
                            goalSave:
                            category.moneyType == MoneyType.save
                                ? int.tryParse(updatedGoalSave!)
                                : null,
                          );
                          context.read<CategoryBloc>().add(
                            UpdateCategory(updatedCategory),
                          );
                          context.pop();
                          DialogUtils.isSuccessDialog(
                            context,
                            'Updated $updatedName',
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity * 0.8,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.caribbeanGreen,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        context.read<CategoryBloc>().add(
                          DeleteCategory(category.id),
                        );
                        context.pop();
                        DialogUtils.isSuccessDialog(
                          context,
                          'Deleted ${category.categoryType}',
                        );
                      },
                      child: Container(
                        width: double.infinity * 0.8,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.oceanBlue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: double.infinity * 0.8,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.fenceGreen,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Opacity(
        opacity: hasTransactions ? 1.0 : 0.4,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.fenceGreen.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                CategoryIconUtils.getCategoriesIconPath(
                  category.categoryType,
                  category.moneyType,
                ),
                width: 40,
                height: 40,
                colorFilter: const ColorFilter.mode(
                  AppColors.honeydew,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.categoryType,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreCategoryGridItem(BuildContext context, MoneyType moneyType) {
    return GestureDetector(
      onTap: () async {
        String? newCategoryName;
        int? goalSave;

        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) {
            String? inputName;
            String? inputGoalSave;

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'New Category',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (value) => inputName = value,
                        decoration: const InputDecoration(
                          hintText: 'Category Name',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppColors.caribbeanGreen),
                        ),
                        style: const TextStyle(color: AppColors.fenceGreen),
                      ),
                    ),
                    if (moneyType == MoneyType.save) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          onChanged: (value) => inputGoalSave = value,
                          decoration: const InputDecoration(
                            hintText: 'Goal Save Amount',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: AppColors.caribbeanGreen,
                            ),
                          ),
                          style: const TextStyle(color: AppColors.fenceGreen),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        if (inputName != null && inputName!.isNotEmpty) {
                          final categories =
                          CategoryRepository.getAllCategories();
                          if (categories.any(
                                (c) =>
                            c.categoryType.toLowerCase() ==
                                inputName!.toLowerCase() &&
                                c.moneyType == moneyType,
                          )) {
                            SnackbarUtils.showNoticeSnackbar(
                              context,
                              'Category already exists',
                              true,
                            );
                            return;
                          }
                          if (moneyType == MoneyType.save &&
                              (inputGoalSave == null ||
                                  inputGoalSave!.isEmpty)) {
                            SnackbarUtils.showNoticeSnackbar(
                              context,
                              'Goal Save is required',
                              true,
                            );
                            return;
                          }
                          context.pop({
                            'name': inputName,
                            'goalSave':
                            inputGoalSave != null
                                ? int.tryParse(inputGoalSave!)
                                : null,
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity * 0.8,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.caribbeanGreen,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: double.infinity * 0.8,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.fenceGreen,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (result != null &&
            result['name'] != null &&
            result['name'].isNotEmpty) {
          newCategoryName = result['name'];
          goalSave = moneyType == MoneyType.save ? result['goalSave'] : null;

          if (moneyType == MoneyType.save && goalSave == null) {
            if (context.mounted) {
              SnackbarUtils.showNoticeSnackbar(
                context,
                'Invalid Goal Save amount',
                true,
              );
            }
            return;
          }

          final newId =
          CategoryRepository.getAllCategories().isEmpty
              ? 1
              : CategoryRepository.getAllCategories()
              .map((c) => c.id)
              .reduce((a, b) => a > b ? a : b) +
              1;
          final newCategory = CategoryModel(
            newId,
            moneyType,
            newCategoryName!,
            goalSave: goalSave,
          );

          if (context.mounted) {
            context.read<CategoryBloc>().add(AddCategory(newCategory));
            DialogUtils.isSuccessDialog(context, 'Added $newCategoryName');
          }
        }
      },
      child: Transform.scale(
        scale: 1.05,
        child: Opacity(
          opacity: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.caribbeanGreen,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.fenceGreen.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 40, color: AppColors.honeydew),
                SizedBox(height: 8),
                Text(
                  'Add More',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.honeydew,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}