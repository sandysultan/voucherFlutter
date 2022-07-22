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
import 'package:repository/repository.dart' as rep;

part 'capital_event.dart';

part 'capital_state.dart';

var _logger = Logger();

class CapitalBloc extends Bloc<CapitalEvent, CapitalState> {
  CapitalBloc() : super(CapitalInitial()) {
    on<GetGroups>(_getGroups);
    on<GetInvestor>(_getInvestor);
    on<GetCapital>(_getCapital);
    on<GetUsers>(_getUsers);
    on<PickCapitalReceipt>(_pickCapitalReceipt);
    on<CapitalReceiptRetrieved>(_capitalReceiptRetrieved);
    on<AddCapital>(_addCapital);
    on<GetLastClosing>(_getLastClosing);
  }

  Future<void> _getLastClosing(GetLastClosing event, Emitter<CapitalState> emit) async {
    emit(GetLastClosingLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if(token==null){
      emit(const GetLastClosingFailed('Authentication Failed'));
    }else {
      ClosingRepository repository = ClosingRepository(HttpClient.getClient(token: token));
      await repository.getLastClosing(groupName:event.groupName)
          .then((value) {
        if (value?.status == 1) {
          emit(GetLastClosingSuccess(value!.closing));
        } else {
          emit(GetLastClosingFailed(value?.message??"Server error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if(error is DioError){
          emit(GetLastClosingFailed(HttpClient.getDioErrorMessage(error)));
        }else {
          emit(GetLastClosingFailed(error.toString()));
        }
      });
    }
  }

  Future<void> _pickCapitalReceipt(
      PickCapitalReceipt event, Emitter<CapitalState> emit) async {
    emit(PickReceiptStart());
  }

  Future<void> _capitalReceiptRetrieved(
      CapitalReceiptRetrieved event, Emitter<CapitalState> emit) async {
    emit(PickReceiptDone(event.path));
  }

  Future<void> _addCapital(AddCapital event, Emitter<CapitalState> emit) async {
    emit(AddCapitalLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null) {
      emit(const AddCapitalFailed('Please re-login'));
    } else {
      CapitalRepository repository =
          CapitalRepository(HttpClient.getClient(token: token));
      await repository
          .addCapital(
        Capital(
          uid: event.uid,
          date: event.date,
          groupName: event.groupName,
          total: event.total,
        ),
      )
          .then((response) async {
        if (response?.status == 1) {
          await repository
              .uploadReceipt(response!.capital.id!,event.file)
              .then((response2) async {
            if (response2?.status == 1) {
              emit(AddCapitalSuccess(response.capital));
            } else {
              emit(AddCapitalFailed(response2?.message ?? "Server Error"));
            }
          }).catchError((error, stack) {
            _logger.e(error);

            if (!kIsWeb) {
              FirebaseCrashlytics.instance.recordError(error, stack);
            }
            emit(AddCapitalFailed(error.toString()));
          });
        } else {
          emit(AddCapitalFailed(response?.message ?? "Server Error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);

        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        emit(AddCapitalFailed(error.toString()));
      });
    }
  }

  Future<void> _getUsers(GetUsers event, Emitter<CapitalState> emit) async {
    emit(GetUserLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null) {
      emit(const GetUserFailed('Please re-login'));
    } else {
      UserRepository repository =
          UserRepository(HttpClient.getClient(token: token));
      await repository.getUsers(roles: ['investor']).then((response) async {
        if (response?.status == 1) {
          emit(GetUserSuccess(response!.users));
        } else {
          emit(GetUserFailed(response?.message ?? "Server Error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);

        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        emit(GetUserFailed(error.toString()));
      });
    }
  }

  Future<void> _getGroups(GetGroups event, Emitter<CapitalState> emit) async {
    emit(GetGroupLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetGroupFailed('Authentication Failed'));
    } else {
      UserRepository? userRepository =
          UserRepository(HttpClient.getClient(token: token));
      await userRepository.getGroup(event.module).then((value) {
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

  Future<void> _getInvestor(
      GetInvestor event, Emitter<CapitalState> emit) async {
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

  Future<void> _getCapital(GetCapital event, Emitter<CapitalState> emit) async {
    emit(GetCapitalLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetCapitalFailed('Authentication Failed'));
    } else {
      CapitalRepository? repository =
          CapitalRepository(HttpClient.getClient(token: token));
      await repository
          .getCapitals(
              groupName: event.groupName,
              uid: event.uid,
              year: event.year,
              month: event.month)
          .then((value) {
        if (value?.status == 1) {
          emit(GetCapitalSuccess(value!.capitals));
        } else {
          emit(GetCapitalFailed(value?.message ?? "Server error"));
        }
      }).catchError((error, stack) {
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if (error is DioError) {
          emit(GetCapitalFailed(HttpClient.getDioErrorMessage(error)));
        } else {
          emit(GetCapitalFailed(error.toString()));
        }
      });
    }
  }
}
