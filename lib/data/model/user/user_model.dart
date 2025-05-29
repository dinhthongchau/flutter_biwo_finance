import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String mobile;
  final String dob;
  final String password;
  final String? avatarPath;
  final bool helper;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.dob,
    required this.password,
    this.avatarPath,
    this.helper = false,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? mobile,
    String? dob,
    String? password,
    String? avatarPath,
    bool? helper,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      dob: dob ?? this.dob,
      password: password ?? this.password,
      avatarPath: avatarPath ?? this.avatarPath,
      helper: helper ?? this.helper,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    mobile,
    dob,
    password,
    avatarPath,
    helper,
  ];
}
