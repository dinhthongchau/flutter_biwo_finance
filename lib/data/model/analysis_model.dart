import 'package:intl/intl.dart';

abstract class BaseAnalysis {
  final int income;
  final int expense;

  BaseAnalysis(this.income, this.expense);

  String get xValue;
}

class DailyAnalysis extends BaseAnalysis {
  final DateTime day;
  final DateTime startDate;
  final DateTime endDate;

  DailyAnalysis(this.day, this.startDate, this.endDate, int income, int expense)
    : super(income, expense);

  @override
  String get xValue => DateFormat('EEE').format(day);
}

class WeeklyAnalysis extends BaseAnalysis {
  final int weekNumber;
  final DateTime startDate;
  final DateTime endDate;

  WeeklyAnalysis(
    this.weekNumber,
    this.startDate,
    this.endDate,
    int income,
    int expense,
  ) : super(income, expense);

  @override
  String get xValue => 'Week $weekNumber';
}

class MonthlyAnalysis extends BaseAnalysis {
  final int monthNumber;
  final DateTime startDate;
  final DateTime endDate;

  MonthlyAnalysis(
    this.monthNumber,
    this.startDate,
    this.endDate,
    int income,
    int expense,
  ) : super(income, expense);

  @override
  String get xValue => DateFormat('MMM').format(DateTime(2025, monthNumber));
}

class YearAnalysis extends BaseAnalysis {
  final int year;
  final DateTime startDate;
  final DateTime endDate;

  YearAnalysis(this.year, this.startDate, this.endDate, int income, int expense)
    : super(income, expense);

  @override
  String get xValue => year.toString();
}
