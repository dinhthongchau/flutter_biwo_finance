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
class HomeLoading extends HomeState {
  const HomeLoading({required super.selectedTimeFilter});

  HomeLoading.fromState({required HomeState state})
      : super(selectedTimeFilter: state.selectedTimeFilter);
}

class HomeSuccess extends HomeState {
  const HomeSuccess({required super.selectedTimeFilter});
}

class HomeError extends HomeState {
  final String? errorMessage;
  const HomeError({
    required super.selectedTimeFilter,
    required this.errorMessage,
  });
  @override
  List<Object?> get props => [selectedTimeFilter, errorMessage];
}
