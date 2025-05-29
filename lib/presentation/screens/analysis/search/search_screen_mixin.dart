import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:finance_management/presentation/shared_data.dart';

mixin SearchScreenMixin<T extends StatefulWidget> on State<T> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final searchBloc = context.read<SearchBloc>();
    searchBloc.add(const ApplyFiltersEvent());
    _searchController.addListener(() {
      searchBloc.add(ApplyFiltersEvent(query: _searchController.text));
    });
  }
  void _selectDate() async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.honeydew,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(37),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.fenceGreen,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Text('All Dates'),
                  onTap: () {
                    context.read<SearchBloc>().add(const SelectDateSearchEvent(null));
                    context.pop();
                  },
                ),
                ListTile(
                  title: const Text('Select Specific Date'),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: context.read<SearchBloc>().state.selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.caribbeanGreen,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: AppColors.fenceGreen,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if ( context.mounted){
                      if (picked != null) {
                        context.read<SearchBloc>().add(SelectDateSearchEvent(picked));
                      }
                      context.pop();
                    }

                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.honeydew,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final state = context.read<SearchBloc>().state;
        return Container(
          padding: const EdgeInsets.all(37),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.fenceGreen,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: state.allCategories.length,
                  itemBuilder: (context, index) {
                    final category = state.allCategories[index];
                    if (category.moneyType.toString().split('.').last ==
                        state.selectedReportType.toString().split('.').last ||
                        state.selectedReportType == ReportTypeSearch.all) {
                      return ListTile(
                        title: Text(category.categoryType),
                        onTap: () {
                          context.read<SearchBloc>().add(SelectCategorySearchEvent(category));
                          context.pop();
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getCategoryIcon(String categoryType) {
    switch (categoryType.toLowerCase()) {
      case 'food':
        return Assets.iconComponents.iconFood.svg(width: 24, height: 24);
      case 'transport':
        return Assets.iconComponents.iconTransport.svg(width: 24, height: 24);
      case 'medicine':
        return Assets.iconComponents.iconMedicine.svg(width: 24, height: 24);
      case 'groceries':
        return Assets.iconComponents.iconGroceries.svg(width: 24, height: 24);
      case 'rent':
        return Assets.iconComponents.iconRent.svg(width: 24, height: 24);
      case 'entertainment':
        return Assets.iconComponents.iconEntertainment.svg(width: 24, height: 24);
      case 'salary':
        return Assets.iconComponents.iconSalary.svg(width: 24, height: 24);
      case 'travel':
        return Assets.iconComponents.travel.svg(width: 24, height: 24);
      case 'new house':
        return Assets.iconComponents.newHome.svg(width: 24, height: 24);
      case 'wedding':
        return Assets.iconComponents.weddingDay.svg(width: 24, height: 24);
      default:
        return Assets.iconComponents.vector.svg(width: 24, height: 24);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  PreferredSizeWidget buildHeaderNotification(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 25),
      child: Container(
        padding: const EdgeInsets.only(left: 38, right: 36, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.fenceGreen,
                size: 20,
              ),
            ),
            const Text(
              'Search',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.fenceGreen,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.honeydew,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search,
                color: AppColors.fenceGreen,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody(SearchState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 20),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.honeydew,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                _buildFilters(state),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildReportRadio(title: 'All', value: ReportTypeSearch.all, state: state),
                    _buildReportRadio(title: 'Income', value: ReportTypeSearch.income, state: state),
                    _buildReportRadio(title: 'Expense', value: ReportTypeSearch.expense, state: state),
                    _buildReportRadio(title: 'Saving', value: ReportTypeSearch.saving, state: state),
                  ],
                ),
                _buildSearchButton(),
                _buildTransactionsList(state),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppColors.lightBlue),
        ),
      ),
    );
  }

  Widget _buildFilters(SearchState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 37),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.fenceGreen,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _showCategoryPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.selectedCategory?.categoryType ?? 'Select the category',
                    style: TextStyle(
                      color: state.selectedCategory != null
                          ? AppColors.fenceGreen
                          : AppColors.fenceGreen.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.caribbeanGreen,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.fenceGreen,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.selectedDate != null
                        ? DateFormat('dd/MMM/yyyy').format(state.selectedDate!)
                        : 'All Dates',
                    style: const TextStyle(
                      color: AppColors.fenceGreen,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.caribbeanGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRadio({
    required String title,
    required ReportTypeSearch value,
    required SearchState state,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<SearchBloc>().add(SelectReportTypeEvent(value));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<ReportTypeSearch>(
              value: value,
              groupValue: state.selectedReportType,
              onChanged: (ReportTypeSearch? newValue) {
                context.read<SearchBloc>().add(SelectReportTypeEvent(newValue));
              },
              activeColor: AppColors.caribbeanGreen,
            ),
            Text(
              title,
              style: const TextStyle(color: AppColors.fenceGreen, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            context.read<SearchBloc>().add(ApplyFiltersEvent(query: _searchController.text));
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.caribbeanGreen,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Center(
                child: Text(
                  'Search',
                  style: TextStyle(
                    color: AppColors.fenceGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(SearchState state) {
    final transactions = state.filteredTransactions ?? [];
    if (transactions.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: AppColors.lightBlue),
              SizedBox(height: 20),
              Text(
                'No transactions',
                style: TextStyle(color: AppColors.fenceGreen, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(37),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final moneyType = transaction.idCategory.moneyType;
    final color = moneyType == MoneyType.income
        ? AppColors.caribbeanGreen
        : moneyType == MoneyType.expense
        ? AppColors.oceanBlue
        : AppColors.lightBlue;
    final prefix = moneyType == MoneyType.income ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _getCategoryIcon(transaction.idCategory.categoryType),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fenceGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('HH:mm').format(transaction.time)} - ${DateFormat('MMMM dd').format(transaction.time)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.lightBlue,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$prefix\$${NumberFormat('#,###').format(transaction.amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }


}