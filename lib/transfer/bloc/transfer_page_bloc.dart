import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';

part 'transfer_page_event.dart';
part 'transfer_page_state.dart';

class TransferPageBloc extends Bloc<TransferPageEvent, TransferPageState> {
  final logger = Logger();

  TransferPageBloc() : super(TransferPageInitial()) {
    on<SalesRefresh>(_salesRefresh);
    on<AddTransfer>(_addTransfer);
  }


  Future<void> _salesRefresh(SalesRefresh event,
      Emitter<TransferPageState> emit) async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(SalesEmpty());
    } else {
      SalesRepository salesRepository = SalesRepository(
          HttpClient.getClient(token: token));
      await salesRepository.getSales(
        groupName: event.groupName, fundTransferred: false,).then((value) {
        if (value?.status == 1) {
          if (value?.sales?.isEmpty == true) {
            emit(SalesEmpty());
          } else {
            emit(SalesLoaded(value!.sales!));
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


  FutureOr<void> _addTransfer(AddTransfer event, Emitter<TransferPageState> emit) async {
    emit(AddTransferLoading());
    await FirebaseAuth.instance.currentUser?.getIdToken().then((token) async  {

        TransferRepository transferRepository = TransferRepository(
            HttpClient.getClient(token: token));
        await transferRepository.addTransfer(event.transfer).then((value) async {
          if (value?.status == 1) {
            await transferRepository.uploadReceipt(value!.transfer.id!, File(event.receipt));
            emit(AddTransferSuccess(value.transfer));
          } else {
            emit(AddTransferError(value?.message??""));
          }
        }).catchError((error, stack) {
          emit(AddTransferError(error.toString()));
          logger.e(error);
          FirebaseCrashlytics.instance.recordError(error, stack);
        });

    }).catchError((error, stack) {
      emit(AddTransferError(error.toString()));
      logger.e(error);
      FirebaseCrashlytics.instance.recordError(error, stack);
    });

  }
}
