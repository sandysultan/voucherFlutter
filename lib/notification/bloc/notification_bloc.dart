import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

var _logger = Logger();

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<NotificationRefresh>(_notificationRefresh);
  }
}

Future<void> _notificationRefresh(
    NotificationRefresh event, Emitter<NotificationState> emit) async {
  emit(NotificationLoading());
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
  if (token == null) {
    emit(const NotificationEmpty('Please re-login'));
  } else {
    NotificationRepository expenseRepository =
    NotificationRepository(HttpClient.getClient(token: token));
    await expenseRepository
        .getNotification()
        .then((value) {
      if (value?.status == 1) {
        if (value?.notifications.isEmpty == true) {
          emit(const NotificationEmpty('No notification at this time'));
        } else {
          emit(NotificationLoaded(value!.notifications));
        }
      } else {
        emit(NotificationEmpty(value?.message ?? "Server Error"));
      }
    }).catchError((error, stack) {
      _logger.e(error);
      if(!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }
      emit(NotificationEmpty(error.toString()));
    });
  }
}
