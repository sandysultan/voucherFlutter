import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';


part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  UserRepository? repository;
  final logger = Logger();
  HomeBloc() : super(HomeInitial()) {
    on<LoadModules>(_loadModules);
    on<AppbarAction>((event,emit){
      logger.d('AppBarClicked ${event.id}');
      emit(AppBarClicked(event.id));});
    on<UpdateFCM>(_updateFCM);
  }

  Future<void> _loadModules(LoadModules event, Emitter<HomeState> emit) async {

    try {
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      repository = UserRepository(HttpClient.getClient(token: token));
      await repository!.getUserModules(event.uid).then((value) {
        if (value?.status == 1) {
          if (value?.modules.isEmpty == true) {
            emit(const EmptyRole('You don' 't have any role, please contact admin'));
          } else {
            emit(RoleLoaded(value!.modules));
          }
        } else {
          emit(EmptyRole(value?.message??'You don' 't have any role, please contact admin'));
        }
      }).catchError((error, stack) {
        logger.e(error);
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        if(error is DioError){
          emit(EmptyRole(HttpClient.getDioErrorMessage(error)));
        }else {
          emit(EmptyRole(error.toString()));
        }
      });
    }catch(error,stack){
      logger.e(error);
      if(!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }

      if(error is DioError){
        emit(EmptyRole(HttpClient.getDioErrorMessage(error)));
      }else {
        emit(EmptyRole(error.toString()));
      }
    }
  }

  Future<void> _updateFCM(UpdateFCM event, Emitter<HomeState> emit) async {

    try {
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      repository = UserRepository(HttpClient.getClient(token: token));
      if(event.fcm==null){

        await repository!.deleteFcm().then((value) {
          if (value?.status == 1) {
            logger.d('fcm updated');
          } else {
            logger.d('fcm update failed');
          }
        }).catchError((error, stack) {
          logger.e(error);
          if(!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(error, stack);
          }
        });
      }else {
        await repository!.updateFcm(event.fcm!).then((value) {
          if (value?.status == 1) {
            logger.d('fcm updated');
          } else {
            logger.d('fcm update failed');
          }
        }).catchError((error, stack) {
          logger.e(error);
          if(!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(error, stack);
          }
        });
      }
      } catch (error, stack) {
      logger.e(error);
      FirebaseCrashlytics.instance.recordError(error, stack);
    }

  }
}
