import 'package:equatable/equatable.dart';
import 'package:finance_management/presentation/shared_data.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionsEvent extends TransactionEvent {
  final String? month; // Make 'month' optional

  const LoadTransactionsEvent({this.month});

  @override
  List<Object?> get props => [month];
}

class UserChangedEvent extends TransactionEvent {
  final String userId;

  const UserChangedEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SelectMonthEvent extends TransactionEvent {
  final String selectedMonth;

  const SelectMonthEvent(this.selectedMonth);

  @override
  List<Object?> get props => [selectedMonth];
}

class SelectFilterTypeEvent extends TransactionEvent {
  final MoneyType? filterType;

  const SelectFilterTypeEvent(this.filterType);

  @override
  List<Object?> get props => [filterType];
}

class AddTransactionEvent extends TransactionEvent {
  final TransactionModel newTransaction;

  const AddTransactionEvent(this.newTransaction);

  @override
  List<Object?> get props => [newTransaction];
}

class FilterTransactionsByTimeframeEvent extends TransactionEvent {
  final ListTransactionFilter filterType;

  const FilterTransactionsByTimeframeEvent(this.filterType);

  @override
  List<Object> get props => [filterType];
}

//DeleteTransactionEvent
class DeleteTransactionEvent extends TransactionEvent {
  final int transactionId;

  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class EditTransactionEvent extends TransactionEvent {
  final TransactionModel updatedTransaction;

  const EditTransactionEvent(this.updatedTransaction);
  @override
  List<Object?> get props => [updatedTransaction];
}
