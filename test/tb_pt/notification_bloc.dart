import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_management/presentation/bloc/notification/notification_event.dart';
import 'package:finance_management/presentation/bloc/notification/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationState()) {
    on<NotificationReceived>((event, emit) {
      emit(state.copyWith(hasNewMessage: true));
    });
    on<NotificationRead>((event, emit) {
      emit(state.copyWith(hasNewMessage: false));
    });
  }
}