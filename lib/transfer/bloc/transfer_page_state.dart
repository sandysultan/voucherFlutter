part of 'transfer_page_bloc.dart';

abstract class TransferPageState extends Equatable {
  const TransferPageState();
  @override
  List<Object> get props => [];
}

class TransferPageInitial extends TransferPageState {
  @override
  List<Object> get props => [];
}

class SalesLoaded extends TransferPageState {
  final List<Sales> sales;

  const SalesLoaded(this.sales);

  @override
  List<Object> get props => [sales];
}

class SalesListLoaded extends TransferPageState {
  final List<Sales> sales;

  const SalesListLoaded(this.sales);

  @override
  List<Object> get props => [sales];
}

class SalesEmpty extends TransferPageState {
}

class AddTransferLoading extends TransferPageState {
}

class AddTransferError extends TransferPageState {
  final String message;

  const AddTransferError(this.message);

  @override
  List<Object> get props => [message];
}

class AddTransferSuccess extends TransferPageState {
  final Transfer transfer;

  const AddTransferSuccess(this.transfer);

  @override
  List<Object> get props => [transfer];

}

class GetGroupLoading extends TransferPageState {
}

class GetGroupSuccess extends TransferPageState {
  final List<String> group;

  const GetGroupSuccess(this.group);

  @override
  List<Object> get props => [group];
}

class GetGroupFailed extends TransferPageState {
  final String message;

  const GetGroupFailed(this.message);

  @override
  List<Object> get props => [message];
}


