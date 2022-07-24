part of 'deposit_bloc.dart';

abstract class DepositState extends Equatable {
  const DepositState();
  @override
  List<Object?> get props => [];
}

class DepositInitial extends DepositState {
}


class GetGroupLoading extends DepositState {
}

class GetGroupSuccess extends DepositState {
  final List<String> group;

  const GetGroupSuccess(this.group);

  @override
  List<Object> get props => [group];
}

class GetGroupFailed extends DepositState {
  final String message;

  const GetGroupFailed(this.message);

  @override
  List<Object> get props => [message];
}


class GetDepositLoading extends DepositState {
}

class GetDepositSuccess extends DepositState {
  final List<Deposit> deposits;

  const GetDepositSuccess(this.deposits);

  @override
  List<Object> get props => [deposits];
}

class GetDepositFailed extends DepositState {
  final String message;

  const GetDepositFailed(this.message);

  @override
  List<Object> get props => [message];
}
