import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:http_client/http_client.dart';
import 'package:iVoucher/constant/app_constant.dart';
import 'package:repository/repository.dart';

part 'deposit_event.dart';

part 'deposit_state.dart';

class DepositBloc extends Bloc<DepositEvent, DepositState> {
  DepositBloc() : super(DepositInitial()) {
    on<GetGroups>(_getGroups);
    on<GetDeposit>(_getDeposit);
  }

  Future<void> _getDeposit(GetDeposit event, Emitter<DepositState> emit) async {
    emit(GetDepositLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetDepositFailed('Authentication Failed'));
    } else {
      DepositRepository? repository =
          DepositRepository(HttpClient.getClient(token: token));
      await repository
          .getDeposits(
              groupName: event.groupName, year: event.year, month: event.month)
          .then((value) {
        if (value?.status == 1) {
          emit(GetDepositSuccess(value!.deposits));
        } else {
          emit(GetDepositFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if (error is DioError) {
          emit(GetDepositFailed(HttpClient.getDioErrorMessage(error)));
        } else {
          emit(GetDepositFailed(error.toString()));
        }
      });
    }
  }

  Future<void> _getGroups(GetGroups event, Emitter<DepositState> emit) async {
    emit(GetGroupLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetGroupFailed('Authentication Failed'));
    } else {
      UserRepository? userRepository =
          UserRepository(HttpClient.getClient(token: token));
      await userRepository.getGroup(ModuleConstant.deposit).then((value) {
        if (value?.status == 1) {
          emit(GetGroupSuccess(value!.groups));
        } else {
          emit(GetGroupFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        if (!kIsWeb) {
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
