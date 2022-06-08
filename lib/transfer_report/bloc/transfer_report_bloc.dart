
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';

part 'transfer_report_event.dart';
part 'transfer_report_state.dart';

var _logger=Logger();

class TransferReportBloc extends Bloc<TransferReportEvent, TransferReportState> {
  TransferReportBloc() : super(TransferReportInitial()) {
    on<GetGroups>(_getGroups);
    on<TransferRefresh>(_transferRefresh);
  }


  Future<void> _transferRefresh(
      TransferRefresh event, Emitter<TransferReportState> emit) async {
    emit(TransferLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null) {
      emit(const TransferEmpty('Please re-login'));
    } else {
      TransferRepository transferRepository =
      TransferRepository(HttpClient.getClient(token: token));
      await transferRepository
          .getTransfer(
          groupName: event.groupName,
          year: event.year,
          month: event.month)
          .then((value) {
        if (value?.status == 1) {
          if (value?.transfers.isEmpty == true) {
            emit(const TransferEmpty('No transfer at this time'));
          } else {
            emit(TransferLoaded(value!.transfers));
          }
        } else {
          emit(TransferEmpty(value?.message ?? "Server Error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        emit(TransferEmpty(error.toString()));
      });
    }
  }

  Future<void> _getGroups(
      GetGroups event, Emitter<TransferReportState> emit) async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetGroupFailed('Authentication Failed'));
    } else {
      UserRepository userRepository =
      UserRepository(HttpClient.getClient(token: token));
      await userRepository.getGroup('salesReport').then((value) {
        if (value?.status == 1) {
          Logger().d(value!.groups);
          emit(GetGroupSuccess(value.groups));
        } else {
          emit(GetGroupFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);
        if(!kIsWeb) {
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
