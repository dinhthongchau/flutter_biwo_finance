import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_management/data/model/notification/notification_model.dart';
import 'package:finance_management/presentation/bloc/notification/notification_event.dart';
import 'package:finance_management/presentation/bloc/notification/notification_state.dart';
import 'package:flutter/material.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationInitial(
    notifications: [],
    notificationCount: 0,
  )) {
    on<AddNotification>(_onAddNotification);
    on<ClearNotifications>(_onClearNotifications);
    on<LoadNotifications>(_onLoadNotifications);
  }

  Future<void> _onAddNotification(AddNotification event,
      Emitter<NotificationState> emit,) async {
    emit(NotificationLoading.fromState(state: state));
    try {
      //for 15 times
      // for (int i = 1; i <= 15; i++) {
      //   NotificationModel.addNotification(event.notification);
      // }
      NotificationModel.addNotification(event.notification);

      final updatedNotifications = List<NotificationModel>.from(
          NotificationModel.getNotifications());
      emit(NotificationSuccess(
        notifications: updatedNotifications,
        notificationCount: updatedNotifications.length,
      ));
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to add notification: ${e.toString()}';
      debugPrint('Stack trace: $stackTrace');
      emit(NotificationError(
        notifications: state.notifications,
        notificationCount: state.notificationCount,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onClearNotifications(ClearNotifications event,
      Emitter<NotificationState> emit,) async {
    emit(NotificationLoading.fromState(state: state));
    try {
      NotificationModel.getNotifications().clear();
      emit(const NotificationSuccess(
        notifications: [],
        notificationCount: 0,
      ));
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to clear notifications: ${e.toString()}';
      debugPrint('Stack trace: $stackTrace');
      emit(NotificationError(
        notifications: state.notifications,
        notificationCount: state.notificationCount,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onLoadNotifications(LoadNotifications event,
      Emitter<NotificationState> emit,) async {
    emit(NotificationLoading.fromState(state: state));
    try {
      final notifications = NotificationModel.getNotifications();
      emit(NotificationSuccess(
        notifications: notifications,
        notificationCount: notifications.length,
      ));
    } catch (e, stackTrace) {
      String errorMessage = 'Failed to load notifications: ${e.toString()}';
      debugPrint('Stack trace: $stackTrace');
      emit(NotificationError(
        notifications: state.notifications,
        notificationCount: state.notificationCount,
        errorMessage: errorMessage,
      ));
    }
  }
}