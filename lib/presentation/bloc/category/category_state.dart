part of 'category_bloc.dart';

abstract class CategoryState extends Equatable {
  final List<CategoryModel> categories;
  final String? errorMessage;

  const CategoryState({
    this.categories = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [categories, errorMessage];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial() : super(categories: const []);
}

class CategoryLoading extends CategoryState {
  const CategoryLoading({super.categories});

  CategoryLoading.fromState({required CategoryState state})
      : super(categories: state.categories);
}

class CategorySuccess extends CategoryState {
  const CategorySuccess({required super.categories});
}

class CategoryError extends CategoryState {
  const CategoryError({required super.errorMessage, super.categories});
}