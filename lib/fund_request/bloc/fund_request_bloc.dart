import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:repository/repository.dart' as repository;
import 'package:voucher/constant/app_constant.dart';

part 'fund_request_event.dart';

part 'fund_request_state.dart';

var _logger = Logger();

class FundRequestBloc extends Bloc<FundRequestEvent, FundRequestState> {
  FundRequestBloc() : super(FundRequestInitial()) {
    on<GetGroups>(_getGroups);
    on<GetExpenseType>(_getExpenseType);
    on<GetFinanceUsers>(_getFinanceUsers);
    on<AddFundRequest>(_addFundRequest);
    on<GetUnpaid>(_getUnpaid);
    on<GetPaid>(_getPaid);
    on<GetModulesPay>(_getModulesPay);
  }
}

Future<void> _getModulesPay(GetModulesPay event, Emitter<FundRequestState> emit) async {
  emit(GetModulePayLoading());
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token == null) {
    emit(const GetModulePayError('Authentication Failed'));
  } else {
    UserRepository repository =
    UserRepository(HttpClient.getClient(token: token));
    await repository
        .getGroup(ModuleConstant.fundRequestPay)
        .then((request) async {
      if (request?.status == 1) {
        emit(GetModulePaySuccess(request!.groups));
      } else {
        emit(GetModulePayError(request?.message ?? "Server error"));
      }
    }).catchError((error, stack) {
      _logger.e(error);
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }

      if (error is DioError) {
        emit(GetModulePayError(HttpClient.getDioErrorMessage(error)));
      } else {
        emit(GetModulePayError(error.toString()));
      }
    });
  }
}

Future<void> _getPaid(GetPaid event, Emitter<FundRequestState> emit) async {
  emit(GetPaidLoading());
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token == null) {
    emit(const GetPaidFailed('Authentication Failed'));
  } else {
    FundRequestRepository repository =
        FundRequestRepository(HttpClient.getClient(token: token));
    await repository
        .getFundRequest(paid: true, year: event.year, month: event.month)
        .then((request) async {
      if (request?.status == 1) {
        emit(GetPaidSuccess(request!.fundRequests));
      } else {
        emit(GetPaidFailed(request?.message ?? "Server error"));
      }
    }).catchError((error, stack) {
      _logger.e(error);
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }

      if (error is DioError) {
        emit(GetPaidFailed(HttpClient.getDioErrorMessage(error)));
      } else {
        emit(GetPaidFailed(error.toString()));
      }
    });
  }
}

Future<void> _getUnpaid(GetUnpaid event, Emitter<FundRequestState> emit) async {
  emit(GetUnpaidLoading());
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token == null) {
    emit(const GetUnpaidFailed('Authentication Failed'));
  } else {
    FundRequestRepository repository =
        FundRequestRepository(HttpClient.getClient(token: token));
    await repository.getFundRequest(paid: false).then((request) async {
      if (request?.status == 1) {
        emit(GetUnpaidSuccess(request!.fundRequests));
      } else {
        emit(GetUnpaidFailed(request?.message ?? "Server error"));
      }
    }).catchError((error, stack) {
      _logger.e(error);
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }

      if (error is DioError) {
        emit(GetUnpaidFailed(HttpClient.getDioErrorMessage(error)));
      } else {
        emit(GetUnpaidFailed(error.toString()));
      }
    });
  }
}

Future<void> _addFundRequest(
    AddFundRequest event, Emitter<FundRequestState> emit) async {
  emit(AddFundRequestLoading());
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token == null) {
    emit(const AddFundRequestFailed('Authentication Failed'));
  } else {
    FundRequestRepository repository =
        FundRequestRepository(HttpClient.getClient(token: token));
    await repository
        .addFundRequest(FundRequest(
            requestedBy: event.requestedBy,
            expenseTypeId: event.expenseType.id,
            description:event.description,
            fundRequestDetails: event.groups
                .map((e) => FundRequestDetail(groupName: e))
                .toList(),
            total: event.total))
        .then((request) async {
      if (request?.status == 1) {
        await repository
            .uploadReceipt(request!.fundRequest.id!, File(event.imagePath))
            .then((value) {
          if (value?.status == 1) {
            emit(AddFundRequestSuccess(request.fundRequest));
          } else {
            emit(AddFundRequestFailed(value?.message ?? "Server Error"));
          }
        });
      } else {
        emit(AddFundRequestFailed(request?.message ?? "Server error"));
      }
    }).catchError((error, stack) {
      _logger.e(error);
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }

      if (error is DioError) {
        emit(AddFundRequestFailed(HttpClient.getDioErrorMessage(error)));
      } else {
        emit(AddFundRequestFailed(error.toString()));
      }
    });
  }
}

Future<void> _getFinanceUsers(
    GetFinanceUsers event, Emitter<FundRequestState> emit) async {
  emit(GetFinanceUserLoading());
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token == null) {
    emit(const GetFinanceUserFailed('Authentication Failed'));
  } else {
    UserRepository userRepository =
        UserRepository(HttpClient.getClient(token: token));
    await userRepository.getUsers(roles: ['finance']).then((value) {
      if (value?.status == 1) {
        _logger.d(value!.users);
        emit(GetFinanceUserSuccess(value.users));
      } else {
        emit(GetFinanceUserFailed(value?.message ?? "Server error"));
      }
    }).catchError((error, stack) {
      _logger.e(error);
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }

      if (error is DioError) {
        emit(GetFinanceUserFailed(HttpClient.getDioErrorMessage(error)));
      } else {
        emit(GetFinanceUserFailed(error.toString()));
      }
    });
  }
}

Future<void> _getGroups(GetGroups event, Emitter<FundRequestState> emit) async {
  emit(GetGroupLoading());
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token == null) {
    emit(const GetGroupFailed('Authentication Failed'));
  } else {
    UserRepository userRepository =
        UserRepository(HttpClient.getClient(token: token));
    await userRepository.getGroup(ModuleConstant.fundRequest).then((value) {
      if (value?.status == 1) {
        _logger.d(value!.groups);
        emit(GetGroupSuccess(value.groups));
      } else {
        emit(GetGroupFailed(value?.message ?? "Server error"));
      }
    }).catchError((error, stack) {
      _logger.e(error);
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

Future<void> _getExpenseType(
    GetExpenseType event, Emitter<FundRequestState> emit) async {
  emit(GetExpenseTypeLoading());
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token == null) {
    emit(const GetExpenseTypeError('Authentication Failed'));
  } else {
    ExpenseRepository repository =
        ExpenseRepository(HttpClient.getClient(token: token));
    await repository.getExpenseTypes().then((value) {
      if (value?.status == 1) {
        emit(GetExpenseTypeSuccess(value!.expenseTypes));
      } else {
        emit(GetExpenseTypeError(value?.message ?? "Server error"));
      }
    }).catchError((error, stack) {
      _logger.e(error);
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }

      if (error is DioError) {
        emit(GetExpenseTypeError(HttpClient.getDioErrorMessage(error)));
      } else {
        emit(GetExpenseTypeError(error.toString()));
      }
    });
  }
}
