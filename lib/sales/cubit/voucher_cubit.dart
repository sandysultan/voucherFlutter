import 'package:bloc/bloc.dart';
import 'package:repository/repository.dart';
import 'package:http_client/http_client.dart';
import 'package:equatable/equatable.dart';


part 'voucher_state.dart';

class VoucherCubit extends Cubit<VoucherState> {
  late VoucherRepository voucherRepository;
  VoucherCubit(String token) : super(VoucherInitial()){
    voucherRepository = VoucherRepository(HttpClient.getClient(token: token));
  }

  Future<void> loadVouchers() async {
    emit(VoucherLoading());
    var vouchers = await voucherRepository.getVoucher();
    if(vouchers!=null){
      emit(VoucherLoaded(vouchers.vouchers));
    }else {
      emit(VoucherLoadFailed());
    }
  }

}
