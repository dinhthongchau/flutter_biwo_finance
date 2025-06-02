part of 'category_bloc.dart';

abstract class CategoryState extends Equatable {
  final List<CategoryModel> categories;


  const CategoryState({
    this.categories = const [],
  });

  @override
  List<Object?> get props => [categories];
}

class CategoryInitial extends CategoryState {
   const CategoryInitial({required super.categories});
   
   @override
   List<Object?> get props => [categories];
}

class CategoryLoading extends CategoryState {
  const CategoryLoading({super.categories});

  CategoryLoading.fromState({required CategoryState state})
      : super(categories: state.categories);
      
  @override
  List<Object?> get props => [categories];
}

class CategorySuccess extends CategoryState {
  const CategorySuccess({required super.categories});
  
  @override
  List<Object?> get props => [categories];
}

class CategoryError extends CategoryState {
  final String? errorMessage;
  const CategoryError({required this.errorMessage, super.categories});
  
  @override
  List<Object?> get props => [categories, errorMessage];
}