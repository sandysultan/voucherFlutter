import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';

part 'sales_kiosk_invoice_event.dart';
part 'sales_kiosk_invoice_state.dart';

class SalesKioskInvoiceBloc extends Bloc<SalesKioskInvoiceEvent, SalesKioskInvoiceState> {
  late KioskRepository kioskRepository;
  final logger = Logger();
  SalesKioskInvoiceBloc(String token) : super(SalesKioskInvoiceInitial()) {
    kioskRepository = KioskRepository(HttpClient.getClient(token: token));
    on<UpdateKioskWhatsapp>(_updateKioskWhatsapp);
  }


  Future<void> _updateKioskWhatsapp(UpdateKioskWhatsapp event, Emitter<SalesKioskInvoiceState> emit) async {
    emit(UpdateWhatsappLoading());
    await kioskRepository.update(event.kiosk.id,event.kiosk).then((value) {
      if(value?.status==1){
        emit(UpdateWhatsappSuccess(value!.kiosk));
      }else{
        emit(UpdateWhatsappError(value?.message??'Network Error'));
      }
    }).catchError((error, stack){
      logger.e(error);
      FirebaseCrashlytics.instance.recordError(error, stack);
      emit(UpdateWhatsappError(error.toString()));
    });

  }
}
