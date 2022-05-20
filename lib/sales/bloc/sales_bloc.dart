import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';

part 'sales_event.dart';
part 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  late SalesRepository salesRepository;
  late KioskRepository kioskRepository;
  final logger = Logger();
  SalesBloc(String token) : super(SalesInitial()) {
    salesRepository = SalesRepository(HttpClient.getClient(token: token));
    kioskRepository = KioskRepository(HttpClient.getClient(token: token));
    on<SalesRefresh>(_salesRefresh);
    on<SalesListRefresh>(_salesListRefresh);
  }


  Future<void> _salesRefresh(SalesRefresh event, Emitter<SalesState> emit) async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if(token==null){
      emit(SalesEmpty());
    }else {
      salesRepository = SalesRepository(HttpClient.getClient(token: token));
      await salesRepository.getSales(event.groupName,event.status,).then((value) {
        if (value?.status == 1) {
          if (value?.kiosks.isEmpty == true) {
            emit(SalesEmpty());
          } else {
            emit(SalesLoaded(value!.kiosks));
          }
        } else {
          emit(SalesEmpty());
        }
      }).catchError((error, stack) {
        logger.e(error);
        FirebaseCrashlytics.instance.recordError(error, stack);
        emit(SalesEmpty());
      });
    }
  }


  Future<void> _salesListRefresh(SalesListRefresh event, Emitter<SalesState> emit) async {
    await kioskRepository.getSales(event.kioskId,event.year,event.month).then((value) {
      if(value?.status==1){
        emit(SalesListLoaded(value!.sales??[]));
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
