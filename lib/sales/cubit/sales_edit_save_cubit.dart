import 'dart:io';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';

part 'sales_edit_save_state.dart';

class SalesEditSaveCubit extends Cubit<SalesEditSaveState> {

  final logger = Logger();
  SalesEditSaveCubit() : super(SalesEditSaveInitial());

  Future<void> save(String token, Sales body,File? receipt,Future<Uint8List>? receiptByte) async {
    var logger = Logger();
    emit(SalesEditSaveLoading());
    try{
      SalesRepository repository = SalesRepository(HttpClient.getClient(token: token));
      var salesResponse = await repository.addSales(body);

      if(salesResponse!=null){
        if(salesResponse.status==1) {
          if(receipt!=null || receiptByte!=null){
            BaseResponse? result;
            if(receiptByte!=null){
              List<int> cache = await receiptByte;
              result = await repository.uploadReceiptForWeb(
                  salesResponse.sales.id!, cache);
            }else {
              result = await repository.uploadReceipt(
                  salesResponse.sales.id!, receipt!);
            }
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

    } on Exception catch (error,stack) {
      logger.e(error);
      if(!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }
      if(error is DioError){
        emit(SalesEditError(HttpClient.getDioErrorMessage(error)));
      }else {
        emit(SalesEditError(error.toString()));
      }
    }
  }
}
