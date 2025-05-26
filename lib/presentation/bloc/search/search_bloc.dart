import 'dart:async';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final TransactionBloc transactionBloc;

  SearchBloc(this.transactionBloc)
      : super(SearchInitial(
    allCategories: CategoryRepository.getAllCategories(),
  )) {
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<SelectCategorySearchEvent>(_onSelectCategory);
    on<SelectDateSearchEvent>(_onSelectDate);
    on<SelectReportTypeEvent>(_onSelectReportType);
  }

  Future<void> _onApplyFilters(
      ApplyFiltersEvent event,
      Emitter<SearchState> emit,
      ) async {
    emit(SearchLoading.fromState(state: state));
    try {
      final transactionState = transactionBloc.state;
      if (transactionState is TransactionSuccess) {
        List<TransactionModel> filtered = transactionState.allTransactions;

        if (event.query != null && event.query!.isNotEmpty) {
          filtered = filtered.where((transaction) {
            return transaction.title.toLowerCase().contains(event.query!.toLowerCase()) ||
                transaction.note.toLowerCase().contains(event.query!.toLowerCase()) ||
                transaction.idCategory.categoryType.toLowerCase().contains(event.query!.toLowerCase());
          }).toList();
        }

        if (state.selectedCategory != null) {
          filtered = filtered.where((transaction) {
            return transaction.idCategory.id == state.selectedCategory!.id;
          }).toList();
        }

        if (state.selectedDate != null) {
          filtered = filtered.where((transaction) {
            return transaction.time.year == state.selectedDate!.year &&
                transaction.time.month == state.selectedDate!.month &&
                transaction.time.day == state.selectedDate!.day;
          }).toList();
        }

        if (state.selectedReportType != null) {
          filtered = filtered.where((transaction) {
            switch (state.selectedReportType!) {
              case ReportTypeSearch.income:
                return transaction.idCategory.moneyType == MoneyType.income;
              case ReportTypeSearch.expense:
                return transaction.idCategory.moneyType == MoneyType.expense;
              case ReportTypeSearch.saving:
                return transaction.idCategory.moneyType == MoneyType.save;
              case ReportTypeSearch.all:
                return true;
            }
          }).toList();
        }

        emit(SearchSuccess(
          filteredTransactions: filtered,
          selectedCategory: state.selectedCategory,
          selectedDate: state.selectedDate,
          selectedReportType: state.selectedReportType,
          allCategories: state.allCategories,
        ));
      } else {
        throw Exception('Transaction data not available');
      }
    } catch (e, stackTrace) {
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = 'Request timed out: ${e.message}';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }
      customPrint('Stack trace: $stackTrace');
      emit(SearchError(
        filteredTransactions: state.filteredTransactions,
        selectedCategory: state.selectedCategory,
        selectedDate: state.selectedDate,
        selectedReportType: state.selectedReportType,
        allCategories: state.allCategories,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onSelectCategory(
      SelectCategorySearchEvent event,
      Emitter<SearchState> emit,
      ) async {
    emit(SearchLoading.fromState(state: state));
    try {
      emit(SearchSuccess(
        filteredTransactions: state.filteredTransactions,
        selectedCategory: event.category,
        selectedDate: state.selectedDate,
        selectedReportType: state.selectedReportType,
        allCategories: state.allCategories,
      ));
      add(const ApplyFiltersEvent());
    } catch (e, stackTrace) {
      String errorMessage = 'Error selecting category: ${e.toString()}';
      customPrint('Stack trace: $stackTrace');
      emit(SearchError(
        filteredTransactions: state.filteredTransactions,
        selectedCategory: state.selectedCategory,
        selectedDate: state.selectedDate,
        selectedReportType: state.selectedReportType,
        allCategories: state.allCategories,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onSelectDate(
      SelectDateSearchEvent event,
      Emitter<SearchState> emit,
      ) async {
    emit(SearchLoading.fromState(state: state));
    try {
      emit(SearchSuccess(
        filteredTransactions: state.filteredTransactions,
        selectedCategory: state.selectedCategory,
        selectedDate: event.date,
        selectedReportType: state.selectedReportType,
        allCategories: state.allCategories,
      ));
      add(const ApplyFiltersEvent());
    } catch (e, stackTrace) {
      String errorMessage = 'Error selecting date: ${e.toString()}';
      customPrint('Stack trace: $stackTrace');
      emit(SearchError(
        filteredTransactions: state.filteredTransactions,
        selectedCategory: state.selectedCategory,
        selectedDate: state.selectedDate,
        selectedReportType: state.selectedReportType,
        allCategories: state.allCategories,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onSelectReportType(
      SelectReportTypeEvent event,
      Emitter<SearchState> emit,
      ) async {
    emit(SearchLoading.fromState(state: state));
    try {
      emit(SearchSuccess(
        filteredTransactions: state.filteredTransactions,
        selectedCategory: null,
        selectedDate: state.selectedDate,
        selectedReportType: event.reportType,
        allCategories: state.allCategories,
      ));
      add(const ApplyFiltersEvent());
    } catch (e, stackTrace) {
      String errorMessage = 'Error selecting report type: ${e.toString()}';
      customPrint('Stack trace: $stackTrace');
      emit(SearchError(
        filteredTransactions: state.filteredTransactions,
        selectedCategory: state.selectedCategory,
        selectedDate: state.selectedDate,
        selectedReportType: state.selectedReportType,
        allCategories: state.allCategories,
        errorMessage: errorMessage,
      ));
    }
  }
}