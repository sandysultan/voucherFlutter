part of 'capital_bloc.dart';

abstract class CapitalState extends Equatable {
  const CapitalState();
  @override
  List<Object?> get props => [];
}

class CapitalInitial extends CapitalState {
}


class GetGroupLoading extends CapitalState {
}

class GetGroupSuccess extends CapitalState {
  final List<String> group;

  const GetGroupSuccess(this.group);

  @override
  List<Object> get props => [group];
}

class GetGroupFailed extends CapitalState {
  final String message;

  const GetGroupFailed(this.message);

  @override
  List<Object> get props => [message];
}


class GetInvestorLoading extends CapitalState {
}

class GetInvestorSuccess extends CapitalState {
  final List<rep.User> users;

  const GetInvestorSuccess(this.users);

  @override
  List<Object> get props => [users];
}

class GetInvestorFailed extends CapitalState {
  final String message;

  const GetInvestorFailed(this.message);

  @override
  List<Object> get props => [message];
}


class GetCapitalLoading extends CapitalState {
}

class GetCapitalSuccess extends CapitalState {
  final List<Capital> capitals;

  const GetCapitalSuccess(this.capitals);

  @override
  List<Object> get props => [capitals];
}

class GetCapitalFailed extends CapitalState {
  final String message;

  const GetCapitalFailed(this.message);

  @override
  List<Object> get props => [message];
}

class GetUserLoading extends CapitalState {
}

class GetUserSuccess extends CapitalState {
  final List<rep.User> users;

  const GetUserSuccess(this.users);

  @override
  List<Object> get props => [users];
}

class GetUserFailed extends CapitalState {
  final String message;

  const GetUserFailed(this.message);

  @override
  List<Object> get props => [message];
}

class PickReceiptStart extends CapitalState {
}

class PickReceiptDone extends CapitalState {
  final String path;

  const PickReceiptDone(this.path);

  @override
  List<Object> get props => [path];
}

class AddCapitalLoading extends CapitalState {
}

class AddCapitalSuccess extends CapitalState {
  final Capital capital;

  const AddCapitalSuccess(this.capital);

  @override
  List<Object> get props => [capital];
}

class AddCapitalFailed extends CapitalState {
  final String message;

  const AddCapitalFailed(this.message);

  @override
  List<Object> get props => [message];
}



class GetLastClosingLoading extends CapitalState {
}

class GetLastClosingSuccess extends CapitalState {
  final Closing? closing;

  const GetLastClosingSuccess(this.closing);

  @override
  List<Object> get props => [if(closing!=null)[closing]];
}

class GetLastClosingFailed extends CapitalState {
  final String message;

  const GetLastClosingFailed(this.message);

  @override
  List<Object> get props => [message];
}