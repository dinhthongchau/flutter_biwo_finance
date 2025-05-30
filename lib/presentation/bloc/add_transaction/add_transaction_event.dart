import 'package:equatable/equatable.dart';
import 'package:finance_management/data/model/transaction/category_model.dart';
import 'package:flutter/material.dart';

abstract class AddTransactionNewEvent extends Equatable {
  const AddTransactionNewEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoriesEvent extends AddTransactionNewEvent {
  final CategoryModel? initialSelectedCategory;

  const LoadCategoriesEvent({this.initialSelectedCategory});

  @override
  List<Object?> get props => [initialSelectedCategory];
}

class SelectDateEvent extends AddTransactionNewEvent {
  final BuildContext context;

  const SelectDateEvent(this.context);

  @override
  List<Object?> get props => [context];
}

class SelectCategoryEvent extends AddTransactionNewEvent {
  final CategoryModel? category;

  const SelectCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}