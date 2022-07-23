part of 'deposit_bloc.dart';

abstract class DepositEvent extends Equatable {
  const DepositEvent();
  @override
  List<Object?> get props => [];
}


class GetGroups extends DepositEvent {
}