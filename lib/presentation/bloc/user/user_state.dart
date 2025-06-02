import 'package:equatable/equatable.dart';
import 'package:finance_management/data/model/user/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  @override
  List<Object?> get props => [];
}

class UserLoading extends UserState {
  @override
  List<Object?> get props => [];
}

class UserLoaded extends UserState {
  final UserModel user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserUpdated extends UserState {
  final UserModel user;

  const UserUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class UserDeleted extends UserState {
  @override
  List<Object?> get props => [];
}

class UserLoggedIn extends UserState {
  final UserModel user;

  const UserLoggedIn(this.user);

  @override
  List<Object?> get props => [user];
}

class UserRegistered extends UserState {
  final UserModel user;

  const UserRegistered(this.user);

  @override
  List<Object?> get props => [user];
}
