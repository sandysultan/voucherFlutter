
part of 'voucher_cubit.dart';

abstract class VoucherState extends Equatable {
  const VoucherState();
  @override
  List<Object> get props => [];
}

class VoucherInitial extends VoucherState {
}

class VoucherLoading extends VoucherState {
}

class VoucherLoaded extends VoucherState {
  final List<Voucher> vouchers;
  const VoucherLoaded(this.vouchers);

  @override
  List<Object> get props => [vouchers];
}

class VoucherLoadFailed extends VoucherState {
}
