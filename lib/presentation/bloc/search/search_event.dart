import 'package:equatable/equatable.dart';
import 'package:finance_management/presentation/shared_data.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class ApplyFiltersEvent extends SearchEvent {
  final String? query;

  const ApplyFiltersEvent({this.query});

  @override
  List<Object?> get props => [query];
}

class SelectCategorySearchEvent extends SearchEvent {
  final CategoryModel? category;

  const SelectCategorySearchEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class SelectDateSearchEvent extends SearchEvent {
  final DateTime? date;

  const SelectDateSearchEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectReportTypeEvent extends SearchEvent {
  final ReportTypeSearch? reportType;

  const SelectReportTypeEvent(this.reportType);

  @override
  List<Object?> get props => [reportType];
}