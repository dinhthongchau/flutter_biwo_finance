import 'package:equatable/equatable.dart';
import 'package:finance_management/core/enum/enums.dart';

class HomeState extends Equatable {
  final TimeFilterHome selectedTimeFilter;

  const HomeState({required this.selectedTimeFilter});

  HomeState copyWith({TimeFilterHome? selectedTimeFilter}) {
    return HomeState(
      selectedTimeFilter: selectedTimeFilter ?? this.selectedTimeFilter,
    );
  }

  @override
  List<Object?> get props => [selectedTimeFilter];
}

class HomeInitial extends HomeState {
  const HomeInitial({required super.selectedTimeFilter});
}
