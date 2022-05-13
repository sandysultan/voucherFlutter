import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';

part 'sales_edit_state.dart';

class SalesEditCubit extends Cubit<SalesEditState> {
  late SalesRepository repository;
  final logger = Logger();
  SalesEditCubit(String token) : super(SalesEditInitial()){
    logger.d('token:' + token);
    repository = SalesRepository(HttpClient.getClient(token: token));
  }

  Future<void> save(AddSales body,File? receipt) async {
    var logger = Logger();
    emit(SalesEditLoading());
    try{
      // logger.d(body.toJson());

    var salesResponse = await repository.addSales(body);

    if(salesResponse!=null){
      if(salesResponse.status==1) {
        if(receipt!=null){
          var result = await repository.uploadReceipt(salesResponse.sales.id!, receipt);
          if(result!=null && result.status == 1) {
            emit(SalesEditSaved(salesResponse.sales.copy(receipt: true)));
          }else{
            emit(SalesEditSaved(salesResponse.sales));
          }
        }else{
          emit(SalesEditSaved(salesResponse.sales));
        }
      }else{
        emit(SalesEditError(salesResponse.message));
      }
    }else {
      emit(const SalesEditError('Network error'));
    }

    } on Exception catch (e,stack) {
      logger.e(e);
      FirebaseCrashlytics.instance.recordError(e, stack);
      emit(SalesEditError(e.toString()));
    }
  }
}
