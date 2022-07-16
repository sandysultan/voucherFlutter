import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:http_client/http_client.dart';
import 'package:iVoucher/constant/app_constant.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';

part 'closing_event.dart';
part 'closing_state.dart';

var _logger = Logger();
class ClosingBloc extends Bloc<ClosingEvent, ClosingState> {
  ClosingBloc() : super(ClosingInitial()) {
    on<GetGroups>(_getGroups);
    on<GetStatus>(_getStatus);
    on<Close>(_close);
  }

  Future<void> _close(Close event, Emitter<ClosingState> emit) async {
    emit(CloseLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const CloseFailed('Authentication Failed'));
    } else {
      ClosingRepository repository =
      ClosingRepository(HttpClient.getClient(token: token));
      await repository.close(groupName: event.groupName).then((value) {
        if (value?.status == 1) {
          _logger.d(value!);
          emit(CloseSuccess());
        } else {
          emit(CloseFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if (error is DioError) {
          _logger.e(error);
          emit(CloseFailed(HttpClient.getDioErrorMessage(error)));
        } else {
          emit(CloseFailed(error.toString()));
        }
      });
    }
  }

  Future<void> _getStatus(GetStatus event, Emitter<ClosingState> emit) async {
    emit(GetStatusLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetStatusFailed('Authentication Failed'));
    } else {
      ClosingRepository repository =
      ClosingRepository(HttpClient.getClient(token: token));
      await repository.getStatus(groupName: event.groupName).then((value) {
        if (value?.status == 1) {
          _logger.d(value!);
          emit(GetStatusSuccess(event.groupName,value));
        } else {
          emit(GetStatusFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if (error is DioError) {
          _logger.e(error);
          emit(GetStatusFailed(HttpClient.getDioErrorMessage(error)));
        } else {
          emit(GetStatusFailed(error.toString()));
        }
      });
    }
  }

  Future<void> _getGroups(GetGroups event, Emitter<ClosingState> emit) async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetGroupFailed('Authentication Failed'));
    } else {
      UserRepository userRepository =
      UserRepository(HttpClient.getClient(token: token));
      await userRepository.getGroup(ModuleConstant.closing).then((value) {
        if (value?.status == 1) {
          _logger.d(value!.groups);
          emit(GetGroupSuccess(value.groups));
        } else {
          emit(GetGroupFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if (error is DioError) {
          emit(GetGroupFailed(HttpClient.getDioErrorMessage(error)));
        } else {
          emit(GetGroupFailed(error.toString()));
        }
      });
    }
  }
}


