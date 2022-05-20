import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';


part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  late UserRepository repository;
  final logger = Logger();
  HomeBloc(String token) : super(HomeInitial()) {
    logger.d('token:'+token);
    repository = UserRepository(HttpClient.getClient(token: token));

    on<LoadRolesAndGroups>(_loadRolesAndGroups);
    on<AppbarAction>((event,emit)=>emit(AppBarClicked(event.id)));
  }

  Future<void> _loadRolesAndGroups(LoadRolesAndGroups event, Emitter<HomeState> emit) async {
    await repository.rolesAndGroups(event.uid).then((value) {
      if(value?.status==1){
        if(value?.roles.isEmpty==true) {
          emit(EmptyRole());
        } else {
          emit(RoleLoaded(value!.roles,value.groups));
        }
      }else{
        emit(EmptyRole());
      }
    }).catchError((error,stack){
      logger.e(error);
      FirebaseCrashlytics.instance.recordError(error, stack);
      emit(EmptyRole());
    });

  }
}
