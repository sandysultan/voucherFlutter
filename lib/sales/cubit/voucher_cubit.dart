
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repository/repository.dart';
import 'package:http_client/http_client.dart';
import 'package:equatable/equatable.dart';

part 'voucher_state.dart';

class VoucherCubit extends Cubit<VoucherState> {

  VoucherCubit() : super(VoucherInitial());

  Future<void> loadVouchers(String groupName) async {

    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if(token==null){
      emit(VoucherLoadFailed());
    }else {
      emit(VoucherLoading());
      GroupRepository groupRepository = GroupRepository(
          HttpClient.getClient(token: token));
      var vouchers = await groupRepository.getVouchers(groupName);
      if (vouchers != null) {
        emit(VoucherLoaded(vouchers.vouchers));
      } else {
        emit(VoucherLoadFailed());
      }
    }
  }

}
