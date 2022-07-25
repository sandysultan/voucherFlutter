// TODO Implement this library.
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:http_client/http_client.dart';
import 'package:iVoucher/constant/app_constant.dart';
import 'package:repository/repository.dart';

part 'asset_event.dart';
part 'asset_state.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  AssetBloc() : super(AssetInitial()) {
    on<GetGroups>(_getGroups);
    on<GetAsset>(_getAsset);
  }
  Future<void> _getAsset(GetAsset event, Emitter<AssetState> emit) async {
    emit(GetAssetLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetAssetFailed('Authentication Failed'));
    } else {
      AssetRepository? repository =
      AssetRepository(HttpClient.getClient(token: token));
      await repository
          .getAssets(
          groupName: event.groupName, year: event.year, month: event.month)
          .then((value) {
        if (value?.status == 1) {
          emit(GetAssetSuccess(value!.assets));
        } else {
          emit(GetAssetFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if (error is DioError) {
          emit(GetAssetFailed(HttpClient.getDioErrorMessage(error)));
        } else {
          emit(GetAssetFailed(error.toString()));
        }
      });
    }
  }

  Future<void> _getGroups(GetGroups event, Emitter<AssetState> emit) async {
    emit(GetGroupLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetGroupFailed('Authentication Failed'));
    } else {
      UserRepository? userRepository =
      UserRepository(HttpClient.getClient(token: token));
      await userRepository.getGroup(ModuleConstant.asset).then((value) {
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
