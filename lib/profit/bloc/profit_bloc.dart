import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_client/http_client.dart';
import 'package:iVoucher/constant/app_constant.dart';
import 'package:iVoucher/profit/profit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:repository/repository.dart' as rep;

part 'profit_event.dart';

part 'profit_state.dart';

var _logger = Logger();

class ProfitBloc extends Bloc<ProfitEvent, ProfitState> {
  ProfitBloc() : super(ProfitInitial()) {
    on<GetGroups>(_getGroups);
    on<GetProfit>(_getProfit);
    on<GetInvestor>(_getInvestor);
    on<GetLastClosing>(_getLastClosing);
    on<PickProfitTransferReceipt>(_pickProfitTransferReceipt);
    on<ProfitTransferReceiptRetrieved>(_profitTransferReceiptRetrieved);
    on<ProfitTransfer>(_profitTransfer);
    on<ConvertProfit>(_convertProfit);
  }

  Future<void> _convertProfit(
      ConvertProfit event, Emitter<ProfitState> emit) async {
    emit(ConvertProfitLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null) {
      emit(const ConvertProfitFailed('Please re-login'));
    } else {
      ProfitRepository repository =
          ProfitRepository(HttpClient.getClient(token: token));
      await repository
          .convertProfit(profit: Profit(
        uid: event.uid,
        date: event.date,
        groupName: event.groupName,
        total: event.total,)
      )
          .then((response) async {
        if (response?.status == 1) {
          emit(ConvertProfitSuccess());
        } else {
          emit(ConvertProfitFailed(response?.message ?? "Server Error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);

        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        emit(ProfitTransferFailed(error.toString()));
      });
    }
  }

  Future<void> _profitTransfer(
      ProfitTransfer event, Emitter<ProfitState> emit) async {
    emit(ProfitTransferLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null) {
      emit(const ProfitTransferFailed('Please re-login'));
    } else {
      ProfitRepository repository =
          ProfitRepository(HttpClient.getClient(token: token));
      await repository
          .profitTransfer(
        Profit(
          uid: event.uid,
          date: event.date,
          groupName: event.groupName,
          total: event.total,
        ),
      )
          .then((response) async {
        if (response?.status == 1) {
          await repository
              .uploadReceipt(response!.profit.id!, event.file)
              .then((response2) async {
            if (response2?.status == 1) {
              emit(ProfitTransferSuccess(response.profit));
            } else {
              emit(ProfitTransferFailed(response2?.message ?? "Server Error"));
            }
          }).catchError((error, stack) {
            _logger.e(error);

            if (!kIsWeb) {
              FirebaseCrashlytics.instance.recordError(error, stack);
            }
            emit(ProfitTransferFailed(error.toString()));
          });
        } else {
          emit(ProfitTransferFailed(response?.message ?? "Server Error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);

        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        emit(ProfitTransferFailed(error.toString()));
      });
    }
  }

  Future<void> _pickProfitTransferReceipt(
      PickProfitTransferReceipt event, Emitter<ProfitState> emit) async {
    emit(PickReceiptStart());
  }

  Future<void> _profitTransferReceiptRetrieved(
      ProfitTransferReceiptRetrieved event, Emitter<ProfitState> emit) async {
    emit(PickReceiptDone(event.croppedFile));
  }

  Future<void> _getLastClosing(
      GetLastClosing event, Emitter<ProfitState> emit) async {
    emit(GetLastClosingLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetLastClosingFailed('Authentication Failed'));
    } else {
      ClosingRepository repository =
          ClosingRepository(HttpClient.getClient(token: token));
      await repository.getLastClosing(groupName: event.groupName).then((value) {
        if (value?.status == 1) {
          emit(GetLastClosingSuccess(value!.closing));
        } else {
          emit(GetLastClosingFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if (error is DioError) {
          emit(GetLastClosingFailed(HttpClient.getDioErrorMessage(error)));
        } else {
          emit(GetLastClosingFailed(error.toString()));
        }
      });
    }
  }

  Future<void> _getInvestor(
      GetInvestor event, Emitter<ProfitState> emit) async {
    emit(GetInvestorLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetInvestorFailed('Authentication Failed'));
    } else {
      CapitalRepository? repository =
          CapitalRepository(HttpClient.getClient(token: token));
      await repository.getInvestors(groupName: event.groupName).then((value) {
        if (value?.status == 1) {
          emit(GetInvestorSuccess(value!.users));
        } else {
          emit(GetInvestorFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if (error is DioError) {
          emit(GetInvestorFailed(HttpClient.getDioErrorMessage(error)));
        } else {
          emit(GetInvestorFailed(error.toString()));
        }
      });
    }
  }

  Future<void> _getProfit(GetProfit event, Emitter<ProfitState> emit) async {
    emit(GetProfitLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetProfitFailed('Authentication Failed'));
    } else {
      ProfitRepository? repository =
          ProfitRepository(HttpClient.getClient(token: token));
      await repository
          .getProfits(
              groupName: event.groupName, year: event.year, month: event.month)
          .then((value) {
        if (value?.status == 1) {
          emit(GetProfitSuccess(value!.profits));
        } else {
          emit(GetProfitFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if (error is DioError) {
          emit(GetProfitFailed(HttpClient.getDioErrorMessage(error)));
        } else {
          emit(GetProfitFailed(error.toString()));
        }
      });
    }
  }

  Future<void> _getGroups(GetGroups event, Emitter<ProfitState> emit) async {
    emit(GetGroupLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetGroupFailed('Authentication Failed'));
    } else {
      UserRepository? userRepository =
          UserRepository(HttpClient.getClient(token: token));
      await userRepository.getGroup(ModuleConstant.profit).then((value) {
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
