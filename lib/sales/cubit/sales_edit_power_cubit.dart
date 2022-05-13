import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http_client/http_client.dart';
import 'package:logger/logger.dart';
import 'package:repository/repository.dart';

part 'sales_edit_power_state.dart';

class SalesEditPowerCubit extends Cubit<SalesEditPowerState> {
  late SalesRepository repository;
  final logger = Logger();
  SalesEditPowerCubit(String token) : super(SalesEditPowerInitial()){
    logger.d('token:' + token);
    repository = SalesRepository(HttpClient.getClient(token: token));
  }

  Future<void> get(int id) async {
    var logger = Logger();
    emit(SalesEditPowerLoading());
    try{
      // logger.d(body.toJson());

      var salesResponse = await repository.getLastSalesWithPower(id);

      if(salesResponse!=null){
        if(salesResponse.status==1 && salesResponse.sales!=null) {
            emit(SalesEditPowerSuccess(salesResponse.sales!));
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
}
