import 'package:equatable/equatable.dart';
import 'package:finance_management/presentation/shared_data.dart';

abstract class AnalysisEvent extends Equatable {
  const AnalysisEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnalysisDataEvent extends AnalysisEvent {
  const LoadAnalysisDataEvent();

  @override
  List<Object?> get props => [];
}

class ChangeTimeFilterEvent extends AnalysisEvent {
  final TimeFilterAnalysis timeFilter;

  const ChangeTimeFilterEvent(this.timeFilter);

  @override
  List<Object?> get props => [timeFilter];
}

class ChangeDateRangeEvent extends AnalysisEvent {
  final DateTime startDate;
  final DateTime endDate;

  const ChangeDateRangeEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}