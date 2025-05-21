import 'package:finance_management/data/model/category_model.dart';
import 'package:finance_management/data/model/user_model.dart';

class TransactionModel {
  final UserModel idUser;
  final int id;
  final DateTime time;
  final int amount;
  final CategoryModel idCategory;
  final String title;
  final String note;

  TransactionModel(this.idUser, this.id, this.time, this.amount,
      this.idCategory, this.title, this.note);


}