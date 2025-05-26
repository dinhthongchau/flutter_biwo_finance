import 'package:equatable/equatable.dart';
import 'package:finance_management/core/enum/enums.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class SelectTimeFilterEvent extends HomeEvent {
  final TimeFilterHome timeFilter;

  const SelectTimeFilterEvent(this.timeFilter);

  @override
  List<Object?> get props => [timeFilter];
}
