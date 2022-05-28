import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';

part 'sales_edit_power_state.dart';

class SalesEditPowerCubit extends Cubit<SalesEditPowerState> {

  final logger = Logger();
  SalesEditPowerCubit() : super(SalesEditPowerInitial());


  Future<void> get(int id) async {
    var logger = Logger();
    emit(SalesEditGetPowerLoading());
    try{

      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if(token==null){
        emit(const SalesEditPowerError('Authentication Failed'));
      }else {
        KioskRepository repository = KioskRepository(
            HttpClient.getClient(token: token));
        var salesResponse = await repository.getLastSalesWithPower(id);

        if (salesResponse != null) {
          if (salesResponse.status == 1) {
            emit(SalesEditGetPowerSuccess(salesResponse.sales));
          } else {
            emit(SalesEditPowerError(salesResponse.message));
          }
        } else {
          emit(const SalesEditPowerError('Network error'));
        }
      }
    } on Exception catch (error,stack) {
      logger.e(error);
      FirebaseCrashlytics.instance.recordError(error, stack);

      if(error is DioError){
        emit(SalesEditPowerError(HttpClient.getDioErrorMessage(error)));
      }else {
        emit(SalesEditPowerError(error.toString()));
      }
    }
  }

  Future<void> updatePowerCost(String token, Kiosk kiosk) async {
    var logger = Logger();
    emit(SalesEditUpdatePowerLoading());
    try{
      // logger.d(body.toJson());

      KioskRepository repository = KioskRepository(HttpClient.getClient(token: token));
      var response = await repository.update(kiosk.id,kiosk);

      if(response!=null){
        if(response.status==1 ) {
          emit(SalesEditUpdatePowerSuccess(response.kiosk));
        }else{
          emit(SalesEditUpdatePowerError(response.message));
        }
      }else {
        emit(const SalesEditUpdatePowerError('Network error'));
      }

    } on Exception catch (error,stack) {
      logger.e(error);
      FirebaseCrashlytics.instance.recordError(error, stack);

      if(error is DioError){
        emit(SalesEditUpdatePowerError(HttpClient.getDioErrorMessage(error)));
      }else {
        emit(SalesEditUpdatePowerError(error.toString()));
      }
    }
  }
}
