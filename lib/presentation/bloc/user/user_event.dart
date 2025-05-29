import 'package:equatable/equatable.dart';
import 'package:finance_management/data/model/user/user_model.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserEvent extends UserEvent {
  final String userId;

  const LoadUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUserEvent extends UserEvent {
  final String userId;
  final String? fullName;
  final String? email;
  final String? mobile;
  final String? dob;
  final String? password;

  const UpdateUserEvent({
    required this.userId,
    this.fullName,
    this.email,
    this.mobile,
    this.dob,
    this.password,
  });

  @override
  List<Object?> get props => [userId, fullName, email, mobile, dob, password];
}

class DeleteUserEvent extends UserEvent {
  final String userId;

  const DeleteUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoginEvent extends UserEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends UserEvent {
  final UserModel user;

  const RegisterEvent(this.user);

  @override
  List<Object?> get props => [user];
}
