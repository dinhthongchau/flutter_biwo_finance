import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_management/data/model/user/user_model.dart';
import 'package:finance_management/data/repository/user/user_repository.dart';

// Events
abstract class UserEvent {}

class LoadUserEvent extends UserEvent {
  final String userId;
  LoadUserEvent(this.userId);
}

class LoginEvent extends UserEvent {
  final String email;
  final String password;
  LoginEvent(this.email, this.password);
}

class RegisterEvent extends UserEvent {
  final UserModel user;
  RegisterEvent(this.user);
}

class UpdateUserEvent extends UserEvent {
  final UserModel user;
  UpdateUserEvent(this.user);
}

class DeleteUserEvent extends UserEvent {
  final String userId;
  DeleteUserEvent(this.userId);
}

// States
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;
  UserLoaded(this.user);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

// Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc() : _userRepository = UserRepository(), super(UserInitial()) {
    on<LoadUserEvent>(_onLoadUser);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  void _onLoadUser(LoadUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final user = await _userRepository.getUserById(event.userId);
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserError('User not found'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void _onLogin(LoginEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final user = await _userRepository.getUserByCredentials(
        event.email,
        event.password,
      );
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserError('Invalid credentials'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void _onRegister(RegisterEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final exists = await _userRepository.isEmailExists(event.user.email);
      if (exists) {
        emit(UserError('Email already exists'));
        return;
      }
      final newUser = await _userRepository.addUser(event.user);
      emit(UserLoaded(newUser));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void _onUpdateUser(UpdateUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final updatedUser = await _userRepository.editUser(
        event.user.id,
        event.user,
      );
      if (updatedUser != null) {
        emit(UserLoaded(updatedUser));
      } else {
        emit(UserError('Failed to update user'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void _onDeleteUser(DeleteUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final success = await _userRepository.deleteUser(event.userId);
      if (success) {
        emit(UserInitial());
      } else {
        emit(UserError('Failed to delete user'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
