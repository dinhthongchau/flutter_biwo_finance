import 'package:hive/hive.dart';

class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String mobile;
  final String dob;
  final String password;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.dob,
    required this.password,
  });
}