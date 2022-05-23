part of 'transfer_page_bloc.dart';

abstract class TransferPageEvent extends Equatable {
  const TransferPageEvent();
}

class SalesRefresh extends TransferPageEvent{
  final String groupName;

  SalesRefresh(this.groupName,){
    Logger().d(groupName);
  }

  @override
  List<Object?> get props => [groupName,];

}

class AddTransfer extends TransferPageEvent{
  final Transfer transfer;
  final String receipt;

  const AddTransfer(this.transfer,this.receipt);

  @override
  List<Object?> get props => [transfer,receipt];

}