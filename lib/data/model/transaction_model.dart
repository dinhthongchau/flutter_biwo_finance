import 'package:finance_management/data/model/category_model.dart';
import 'package:finance_management/data/model/user/user_model.dart';

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
  TransactionModel copyWith({
    UserModel? idUser,
    int? id,
    DateTime? time,
    int? amount,
    CategoryModel? idCategory,
    String? title,
    String? note,
  }) {
    return TransactionModel(
      idUser ?? this.idUser,
      id ?? this.id,
      time ?? this.time,
      amount ?? this.amount,
      idCategory ?? this.idCategory,
      title ?? this.title,
      note ?? this.note,
    );
  }

}