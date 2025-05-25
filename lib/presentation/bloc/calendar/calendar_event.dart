import 'package:equatable/equatable.dart';
import 'package:finance_management/presentation/shared_data.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class SelectDateEvent extends CalendarEvent {
  final int day;

  const SelectDateEvent(this.day);

  @override
  List<Object?> get props => [day];
}

class ToggleAllMonthEvent extends CalendarEvent {
  const ToggleAllMonthEvent();

  @override
  List<Object?> get props => [];
}

class ChangeMonthEvent extends CalendarEvent {
  final int month;

  const ChangeMonthEvent(this.month);

  @override
  List<Object?> get props => [month];
}

class ChangeYearEvent extends CalendarEvent {
  final int year;

  const ChangeYearEvent(this.year);

  @override
  List<Object?> get props => [year];
}

class ChangeChartTypeEvent extends CalendarEvent {
  final ChartType chartType;

  const ChangeChartTypeEvent(this.chartType);

  @override
  List<Object?> get props => [chartType];
}

class LoadCalendarTransactionsEvent extends CalendarEvent {
  const LoadCalendarTransactionsEvent();

  @override
  List<Object?> get props => [];
}