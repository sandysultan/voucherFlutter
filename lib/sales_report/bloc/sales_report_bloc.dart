import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';

part 'sales_report_event.dart';

part 'sales_report_state.dart';

class SalesReportBloc extends Bloc<SalesReportEvent, SalesReportState> {
  var logger = Logger();

  SalesReportBloc() : super(SalesReportInitial()) {
    on<GetGroups>(_getGroups);
    on<SalesRefresh>(_salesRefresh);
  }

  Future<void> _salesRefresh(
      SalesRefresh event, Emitter<SalesReportState> emit) async {
    emit(SalesLoading());
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null) {
      emit(const SalesEmpty('Please re-login'));
    } else {
      SalesRepository salesRepository =
          SalesRepository(HttpClient.getClient(token: token));
      await salesRepository
          .getSales(
              groupName: event.groupName,
              groupByKiosk: true,
              year: event.year,
              month: event.month)
          .then((value) {
        if (value?.status == 1) {
          if (value?.sales?.isEmpty == true) {
            emit(const SalesEmpty('No sales at this time'));
          } else {
            int totalCash = 0;
            Map<Kiosk, int> totalCashMap = {};

            for (Kiosk kiosk in value?.kiosks ?? []) {
              int kioskTotalCash = 0;
              for (Sales sale in kiosk.sales ?? []) {
                kioskTotalCash += sale.cash;
              }
              totalCashMap[kiosk] = kioskTotalCash;
              totalCash+=kioskTotalCash;
            }
            emit(SalesLoaded(value!.kiosks!, totalCashMap, totalCash));
          }
        } else {
          emit(SalesEmpty(value?.message ?? "Server Error"));
        }
      }).catchError((error, stack) {
        logger.e(error);
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        emit(SalesEmpty(error.toString()));
      });
    }
  }

  Future<void> _getGroups(
      GetGroups event, Emitter<SalesReportState> emit) async {
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
        logger.e(error);
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
