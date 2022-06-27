// TODO Implement this library.
import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';
import 'package:voucher/constant/app_constant.dart';

part 'expense_event.dart';

part 'expense_state.dart';

var _logger = Logger();

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(ExpensePageInitial()) {
    on<GetGroups>(_getGroups);
    on<ExpenseRefresh>(_expenseRefresh);
    on<AddExpense>(_addExpense);
    on<GetExpenseType>(_getExpenseType);
  }

  Future<void> _addExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    emit(AddExpenseLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null) {
      emit(const AddExpenseError('Please re-login'));
    } else {
      ExpenseRepository expenseRepository =
          ExpenseRepository(HttpClient.getClient(token: token));
      await expenseRepository
          .addExpense(
        event.expense,
      )
          .then((expense) async {
        if (expense?.status == 1) {
          await expenseRepository
              .uploadReceipt(expense!.expense.id!, event.receipt)
              .then((value) {
            if (value?.status == 1) {
              emit(AddExpenseSuccess(expense.expense));
            } else {
              emit(AddExpenseError(value?.message ?? "Server Error"));
            }
          });
        } else {
          emit(AddExpenseError(expense?.message ?? "Server Error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);

        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        emit(AddExpenseError(error.toString()));
      });
    }
  }

  Future<void> _expenseRefresh(
      ExpenseRefresh event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null) {
      emit(const ExpenseEmpty('Please re-login'));
    } else {
      ExpenseRepository expenseRepository =
          ExpenseRepository(HttpClient.getClient(token: token));
      await expenseRepository
          .getExpense(
              groupName: event.groupName, year: event.year, month: event.month)
          .then((value) {
        if (value?.status == 1) {
          if (value?.expenses.isEmpty == true) {
            emit(const ExpenseEmpty('No expense at this time'));
          } else {
            emit(ExpenseLoaded(value!.expenses));
          }
        } else {
          emit(ExpenseEmpty(value?.message ?? "Server Error"));
        }
      }).catchError((error, stack) {
        _logger.e(error);
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        emit(ExpenseEmpty(error.toString()));
      });
    }
  }

  Future<void> _getGroups(GetGroups event, Emitter<ExpenseState> emit) async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      emit(const GetGroupFailed('Authentication Failed'));
    } else {
      UserRepository userRepository =
          UserRepository(HttpClient.getClient(token: token));
      await userRepository.getGroup(ModuleConstant.salesReport).then((value) {
        if (value?.status == 1) {
          _logger.d(value!.groups);
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

  Future<void> _getExpenseType(GetExpenseType event, Emitter<ExpenseState> emit) async {
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
        if(!kIsWeb) {
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
}
