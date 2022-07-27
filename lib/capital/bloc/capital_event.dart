part of 'capital_bloc.dart';

abstract class CapitalEvent extends Equatable {
  const CapitalEvent();

  @override
  List<Object?> get props => [];
}

class GetGroups extends CapitalEvent {
  final String module;
  const GetGroups(this.module);
  @override
  List<Object?> get props => [module];
}

class GetInvestor extends CapitalEvent {
  final String groupName;

  const GetInvestor(this.groupName);

  @override
  List<Object?> get props => [groupName];
}

class GetCapital extends CapitalEvent {
  final String groupName;
  final String? uid;
  final int year;
  final int month;

  const GetCapital(
      {required this.groupName,
      this.uid,
      required this.year,
      required this.month});

  @override
  List<Object?> get props => [groupName, uid, year, month];
}

class GetUsers extends CapitalEvent {
  const GetUsers();
}

class AddCapital extends CapitalEvent {
  final String uid;
  final DateTime date;
  final String groupName;
  final int total;
  final File file;

  const AddCapital({
    required this.uid,
    required this.file,
    required this.date,
    required this.groupName,
    required this.total,
  });

  @override
  List<Object?> get props => [uid, file];
}

class PickCapitalReceipt extends CapitalEvent {
}

class CapitalReceiptRetrieved extends CapitalEvent {
  final CroppedFile croppedFile;

  const CapitalReceiptRetrieved(this.croppedFile);

  @override
  List<Object> get props => [croppedFile];
}


class GetLastClosing extends CapitalEvent{

  final String groupName;
  const GetLastClosing({required this.groupName});

  @override
  List<Object?> get props => [groupName];
}
