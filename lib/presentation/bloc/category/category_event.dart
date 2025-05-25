part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  final MoneyType moneyType;

  const LoadCategories(this.moneyType);

  @override
  List<Object?> get props => [moneyType];
}

class UpdateCategory extends CategoryEvent {
  final CategoryModel category;

  const UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final int categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
class AddCategory extends CategoryEvent {
  final CategoryModel category;

  const AddCategory(this.category);

  @override
  List<Object?> get props => [category];
}