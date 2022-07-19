import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart' as repository;
import 'package:repository/repository.dart';
import 'package:iVoucher/constant/app_constant.dart';

part 'sales_event.dart';
part 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {

  final logger = Logger();
  SalesBloc() : super(SalesInitial()) {
    on<SalesRefresh>(_salesRefresh);
    on<SalesListRefresh>(_salesListRefresh);
    on<GetGroups>(_getGroups);
    on<GetOperator>(_getOperator);
    on<DeleteSales>(_deleteSales);
  }


  Future<void> _deleteSales(DeleteSales event, Emitter<SalesState> emit) async {
    emit(DeleteSalesLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if(token==null){
      emit(const DeleteSalesFailed('Please re login'));
    }else {
      SalesRepository repository = SalesRepository(HttpClient.getClient(token: token));
      await repository.deleteSales(event.id).then((value) {
        if (value?.status == 1) {
            emit(DeleteSalesSuccess());
            emit(SalesListLoaded(event.sales.where((element) => element.id!=event.id).toList(),true));
        } else {
          emit(DeleteSalesFailed(value!.message));

        }
      }).catchError((error, stack) {
        logger.e(error);
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if(error is DioError){
          emit(DeleteSalesFailed(HttpClient.getDioErrorMessage(error)));
        }else {
          emit(DeleteSalesFailed(error.toString()));
        }
      });
    }
  }

  Future<void> _salesRefresh(SalesRefresh event, Emitter<SalesState> emit) async {
    emit(SalesLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if(token==null){
      emit(SalesEmpty());
    }else {
      SalesRepository salesRepository = SalesRepository(HttpClient.getClient(token: token));
      await salesRepository.getSales(groupName:event.groupName,status:event.status,groupByKiosk: true).then((value) {
        if (value?.status == 1) {
          if (value?.kiosks?.isEmpty == true) {
            emit(SalesEmpty());
          } else {
            emit(SalesLoaded(value!.kiosks!));
          }
        } else {
          emit(SalesEmpty());
        }
      }).catchError((error, stack) {
        logger.e(error);
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        emit(SalesEmpty());
      });
    }
  }


  Future<void> _salesListRefresh(SalesListRefresh event, Emitter<SalesState> emit) async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if(token==null){
      emit(SalesEmpty());
    }else {
      KioskRepository kioskRepository = KioskRepository(HttpClient.getClient(token: token));
      await kioskRepository.getSales(event.kioskId, event.year, event.month)
          .then((value) {
        if (value?.status == 1) {
          emit(SalesListLoaded(value!.sales ?? [],value.isLast??false));
        } else {
          emit(SalesEmpty());
        }
      }).catchError((error, stack) {
        logger.e(error);
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        emit(SalesEmpty());
      });
    }
  }


  Future<void> _getGroups(GetGroups event, Emitter<SalesState> emit) async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if(token==null){
      emit(const GetGroupFailed('Authentication Failed'));
    }else {
      UserRepository userRepository = UserRepository(HttpClient.getClient(token: token));
      await userRepository.getGroup(ModuleConstant.sale)
          .then((value) {
        if (value?.status == 1) {
          Logger().d(value!.groups);
          emit(GetGroupSuccess(value.groups));
        } else {
          emit(GetGroupFailed(value?.message??"Server error"));
        }
      }).catchError((error, stack) {
        logger.e(error);
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if(error is DioError){
          emit(GetGroupFailed(HttpClient.getDioErrorMessage(error)));
        }else {
          emit(GetGroupFailed(error.toString()));
        }
      });
    }
  }


  Future<void> _getOperator(GetOperator event, Emitter<SalesState> emit) async {
    emit(GetOperatorsLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if(token==null){
      emit(const GetOperatorsFailed('Authentication Failed'));
    }else {
      GroupRepository groupRepository = GroupRepository(HttpClient.getClient(token: token));
      await groupRepository.getOperators(event.groupName)
          .then((value) {
        if (value?.status == 1) {
          // Logger().d(value!.users);
          emit(GetOperatorsSuccess(value!.operators));
        } else {
          emit(GetOperatorsFailed(value?.message??"Server error"));
        }
      }).catchError((error, stack) {
        logger.e(error);
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }

        if(error is DioError){
          emit(GetOperatorsFailed(HttpClient.getDioErrorMessage(error)));
        }else {
          emit(GetOperatorsFailed(error.toString()));
        }
      });
    }
  }


}
