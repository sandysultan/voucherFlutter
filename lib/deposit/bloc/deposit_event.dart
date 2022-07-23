part of 'deposit_bloc.dart';

abstract class DepositEvent extends Equatable {
  const DepositEvent();
  @override
  List<Object?> get props => [];
}


class GetGroups extends DepositEvent {
}

class GetDeposit extends DepositEvent {
  final String groupName;
  final int year;
  final int month;

  const GetDeposit(this.groupName, this.year, this.month);
}