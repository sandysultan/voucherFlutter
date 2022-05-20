import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';

part 'sales_edit_power_state.dart';

class SalesEditPowerCubit extends Cubit<SalesEditPowerState> {
  late KioskRepository repository;
  final logger = Logger();
  SalesEditPowerCubit(String token) : super(SalesEditPowerInitial()){
    logger.d('token:' + token);
    repository = KioskRepository(HttpClient.getClient(token: token));
  }

  Future<void> get(int id) async {
    var logger = Logger();
    emit(SalesEditGetPowerLoading());
    try{
      // logger.d(body.toJson());

      var salesResponse = await repository.getLastSalesWithPower(id);

      if(salesResponse!=null){
        if(salesResponse.status==1 ) {
            emit(SalesEditGetPowerSuccess(salesResponse.sales));
        }else{
          emit(SalesEditPowerError(salesResponse.message));
        }
      }else {
        emit(const SalesEditPowerError('Network error'));
      }

    } on Exception catch (e,stack) {
      logger.e(e);
      FirebaseCrashlytics.instance.recordError(e, stack);
      emit(SalesEditPowerError(e.toString()));
    }
  }

  Future<void> updatePowerCost(String token, Kiosk kiosk) async {
    var logger = Logger();
    emit(SalesEditUpdatePowerLoading());
    try{
      // logger.d(body.toJson());

      repository = KioskRepository(HttpClient.getClient(token: token));
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

    } on Exception catch (e,stack) {
      logger.e(e);
      FirebaseCrashlytics.instance.recordError(e, stack);
      emit(SalesEditUpdatePowerError(e.toString()));
    }
  }
}
