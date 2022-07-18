import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:repository/repository.dart' as rep;

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final _logger = Logger();

  UserBloc() : super(UserInitial()) {
    on<GetUsers>(_getUsers);
  }


  Future<void> _getUsers(GetUsers event,
      Emitter<UserState> emit) async {
    emit(GetUserLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null) {
      emit(const GetUserFailed('Please re-login'));
    } else {
      UserRepository repository =
      UserRepository(HttpClient.getClient(token: token));
      await repository
          .getUsers()
          .then((response) async {
        if (response?.status == 1) {
          emit(GetUserSuccess(response!.users));
        } else {
          emit(GetUserFailed(response?.message ?? "Server Error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);

        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        emit(GetUserFailed(error.toString()));
      });
    }
  }
}
