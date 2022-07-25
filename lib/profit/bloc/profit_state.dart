part of 'profit_bloc.dart';

abstract class ProfitState extends Equatable {
  const ProfitState();
  @override
  List<Object> get props => [];
}

class ProfitInitial extends ProfitState {
}


class GetGroupLoading extends ProfitState {
}

class GetGroupSuccess extends ProfitState {
  final List<String> group;

  const GetGroupSuccess(this.group);

  @override
  List<Object> get props => [group];
}

class GetGroupFailed extends ProfitState {
  final String message;

  const GetGroupFailed(this.message);

  @override
  List<Object> get props => [message];
}

class GetProfitLoading extends ProfitState {
}

class GetProfitSuccess extends ProfitState {
  final List<Profit> profits;

  const GetProfitSuccess(this.profits);

  @override
  List<Object> get props => [profits];
}

class GetProfitFailed extends ProfitState {
  final String message;

  const GetProfitFailed(this.message);

  @override
  List<Object> get props => [message];
}


class GetInvestorLoading extends ProfitState {
}

class GetInvestorSuccess extends ProfitState {
  final List<rep.User> users;

  const GetInvestorSuccess(this.users);

  @override
  List<Object> get props => [users];
}

class GetInvestorFailed extends ProfitState {
  final String message;

  const GetInvestorFailed(this.message);

  @override
  List<Object> get props => [message];
}

class GetLastClosingLoading extends ProfitState {
}

class GetLastClosingSuccess extends ProfitState {
  final Closing? closing;

  const GetLastClosingSuccess(this.closing);

  @override
  List<Object> get props => [if(closing!=null)[closing]];
}

class GetLastClosingFailed extends ProfitState {
  final String message;

  const GetLastClosingFailed(this.message);

  @override
  List<Object> get props => [message];
}
class PickReceiptStart extends ProfitState {
}

class ConvertProfitLoading extends ProfitState {
}

class ConvertProfitSuccess extends ProfitState {
  final Closing? closing;

  const ConvertProfitSuccess(this.closing);

  @override
  List<Object> get props => [if(closing!=null)[closing]];
}

class ConvertProfitFailed extends ProfitState {
  final String message;

  const ConvertProfitFailed(this.message);

  @override
  List<Object> get props => [message];
}


class ProfitTransferLoading extends ProfitState {
}

class ProfitTransferSuccess extends ProfitState {
  final Profit profit;

  const ProfitTransferSuccess(this.profit);

  @override
  List<Object> get props => [profit];
}

class ProfitTransferFailed extends ProfitState {
  final String message;

  const ProfitTransferFailed(this.message);

  @override
  List<Object> get props => [message];
}

class PickReceiptDone extends ProfitState {
  final String path;

  const PickReceiptDone(this.path);

  @override
  List<Object> get props => [path];
}
