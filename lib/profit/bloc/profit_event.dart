part of 'profit_bloc.dart';

abstract class ProfitEvent extends Equatable {
  const ProfitEvent();
  @override
  List<Object?> get props => [];
}

class GetGroups extends ProfitEvent {
}

class GetProfit extends ProfitEvent {
  final String groupName;
  final int year;
  final int month;

  const GetProfit(this.groupName, this.year, this.month);
}



class GetInvestor extends ProfitEvent {
  final String groupName;

  const GetInvestor(this.groupName);

  @override
  List<Object?> get props => [groupName];
}


class GetLastClosing extends ProfitEvent{

  final String groupName;
  const GetLastClosing({required this.groupName});

  @override
  List<Object?> get props => [groupName];
}


class ProfitTransferReceiptRetrieved extends ProfitEvent {
  final CroppedFile croppedFile;

  const ProfitTransferReceiptRetrieved(this.croppedFile);

  @override
  List<Object> get props => [croppedFile];
}


class PickProfitTransferReceipt extends ProfitEvent {
}



class ProfitTransfer extends ProfitEvent {
  final String uid;
  final DateTime date;
  final String groupName;
  final int total;
  final File file;

  const ProfitTransfer({
    required this.uid,
    required this.file,
    required this.date,
    required this.groupName,
    required this.total,
  });

  @override
  List<Object?> get props => [uid, file,date,groupName,total];
}

class ConvertProfit extends ProfitEvent{
  final String uid;
  final String groupName;
  final DateTime date;
  final int total;

  const ConvertProfit({
    required this.uid,
    required this.groupName,
    required this.date,
    required this.total,
  });

  @override
  List<Object?> get props => [uid, groupName,total];

}