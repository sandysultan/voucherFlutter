import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:http_client/http_client.dart';

part 'sales_event.dart';
part 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  late SalesRepository salesRepository;
  final logger = Logger();
  SalesBloc(String token) : super(SalesInitial()) {
    salesRepository = SalesRepository(HttpClient.getClient(token: token));
    on<SalesRefresh>(_salesRefresh);
  }


  Future<void> _salesRefresh(SalesRefresh event, Emitter<SalesState> emit) async {
    await salesRepository.getSales(event.groupName).then((value) {
      if(value?.status==1){
        if(value?.kiosks.isEmpty==true) {
          emit(SalesEmpty());
        } else {
          emit(SalesLoaded(value!.kiosks));
        }
      }else{
        emit(SalesEmpty());
      }
    }).catchError((error,stack){
      logger.e(error);
      FirebaseCrashlytics.instance.recordError(error, stack);
      emit(SalesEmpty());
    });

  }
}
