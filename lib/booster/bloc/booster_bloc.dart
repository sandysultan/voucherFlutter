import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_client/http_client.dart';
import 'package:repository/repository.dart';
import 'package:repository/repository.dart' as rep;

part 'booster_event.dart';
part 'booster_state.dart';

class BoosterBloc extends Bloc<BoosterEvent, BoosterState> {
  BoosterBloc() : super(BoosterInitial()) {
    on<GetGroups>(_getGroups);
    on<GetBooster>(_getBooster);
    on<DeactivateBooster>(_deactivateBooster);
    on<GetInvestor>(_getInvestor);
    on<AddBoost>(_addBoost);
  }

  Future<void> _addBoost(AddBoost event, Emitter<BoosterState> emit) async {
    emit(AddBoostLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const AddBoostFailed('Authentication Failed'));
    } else {
      BoosterRepository? repository =
      BoosterRepository(HttpClient.getClient(token: token));
      await repository.addBoost(event.booster).then((value) {
        if (value?.status == 1) {
          emit( AddBoostSuccess());
        } else {
          emit(AddBoostFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if (error is DioError) {
          emit(AddBoostFailed(HttpClient.getDioErrorMessage(error)));
        } else {
          emit(AddBoostFailed(error.toString()));
        }
      });
    }
  }

  Future<void> _deactivateBooster(DeactivateBooster event, Emitter<BoosterState> emit) async {
    emit(DeactivateBoosterLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const DeactivateBoosterFailed('Authentication Failed'));
    } else {
      BoosterRepository? repository =
      BoosterRepository(HttpClient.getClient(token: token));
      await repository.deactivate(event.id).then((value) {
        if (value?.status == 1) {
          emit(const DeactivateBoosterSuccess());
        } else {
          emit(DeactivateBoosterFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if (error is DioError) {
          emit(DeactivateBoosterFailed(HttpClient.getDioErrorMessage(error)));
        } else {
          emit(DeactivateBoosterFailed(error.toString()));
        }
      });
    }

  }

  Future<void> _getBooster(GetBooster event, Emitter<BoosterState> emit) async {
      emit(GetBoosterLoading());
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        emit(const GetBoosterFailed('Authentication Failed'));
      } else {

        BoosterRepository? repository =
        BoosterRepository(HttpClient.getClient(token: token));
        await repository.getBooster(groupName:event.groupName).then((value) {
          if (value?.status == 1) {
            emit(GetBoosterSuccess(value!.boosters));
          } else {
            emit(GetBoosterFailed(value?.message ?? "Server error"));
          }
        }).catchError((error, stack) {
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(error, stack);
          }

          if (error is DioError) {
            emit(GetBoosterFailed(HttpClient.getDioErrorMessage(error)));
          } else {
            emit(GetBoosterFailed(error.toString()));
          }
        });
      }

  }

  Future<void> _getGroups(GetGroups event, Emitter<BoosterState> emit) async {
    emit(GetGroupLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetGroupFailed('Authentication Failed'));
    } else {
      UserRepository? repository =
      UserRepository(HttpClient.getClient(token: token));
      await repository.getGroup(event.module).then((value) {
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

  Future<void> _getInvestor(
      GetInvestor event, Emitter<BoosterState> emit) async {
    emit(GetInvestorLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetInvestorFailed('Authentication Failed'));
    } else {
      CapitalRepository? repository =
      CapitalRepository(HttpClient.getClient(token: token));
      await repository.getInvestors(groupName: event.groupName).then((value) {
        if (value?.status == 1) {
          emit(GetInvestorSuccess(value!.users));
        } else {
          emit(GetInvestorFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if (error is DioError) {
          emit(GetInvestorFailed(HttpClient.getDioErrorMessage(error)));
        } else {
          emit(GetInvestorFailed(error.toString()));
        }
      });
    }
  }
}
