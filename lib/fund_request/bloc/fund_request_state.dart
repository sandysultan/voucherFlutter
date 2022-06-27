part of 'fund_request_bloc.dart';

abstract class FundRequestState extends Equatable {
  const FundRequestState();

  @override
  List<Object> get props => [];
}

class FundRequestInitial extends FundRequestState {
}

class GetGroupLoading extends FundRequestState {
}

class GetGroupSuccess extends FundRequestState {
  final List<String> groups;

  const GetGroupSuccess(this.groups);

  @override
  List<Object> get props => [groups];
}

class GetGroupFailed extends FundRequestState {
  final String message;

  const GetGroupFailed(this.message);

  @override
  List<Object> get props => [message];
}



class GetFinanceUserLoading extends FundRequestState {
}

class GetFinanceUserSuccess extends FundRequestState {
  final List<repository.User> users;

  const GetFinanceUserSuccess(this.users);

  @override
  List<Object> get props => [users];
}

class GetFinanceUserFailed extends FundRequestState {
  final String message;

  const GetFinanceUserFailed(this.message);

  @override
  List<Object> get props => [message];
}


class GetExpenseTypeLoading extends FundRequestState {
}

class GetExpenseTypeSuccess extends FundRequestState {

  final List<ExpenseType> expenseTypes;

  const GetExpenseTypeSuccess(this.expenseTypes);

  @override
  List<Object> get props => [expenseTypes];
}

class GetExpenseTypeError extends FundRequestState {
  final String message;

  const GetExpenseTypeError(this.message);

  @override
  List<Object> get props => [message];
}


class AddFundRequestLoading extends FundRequestState {
}

class AddFundRequestSuccess extends FundRequestState {

  final FundRequest fundRequest;

  const AddFundRequestSuccess(this.fundRequest);

  @override
  List<Object> get props => [fundRequest];
}

class AddFundRequestFailed extends FundRequestState {
  final String message;

  const AddFundRequestFailed(this.message);

  @override
  List<Object> get props => [message];
}


class GetUnpaidLoading extends FundRequestState {
}

class GetUnpaidSuccess extends FundRequestState {

  final List<FundRequest> fundRequests;

  const GetUnpaidSuccess(this.fundRequests);

  @override
  List<Object> get props => [fundRequests];
}

class GetUnpaidFailed extends FundRequestState {
  final String message;

  const GetUnpaidFailed(this.message);

  @override
  List<Object> get props => [message];
}


class GetPaidLoading extends FundRequestState {
}

class GetPaidSuccess extends FundRequestState {

  final List<FundRequest> fundRequests;

  const GetPaidSuccess(this.fundRequests);

  @override
  List<Object> get props => [fundRequests];
}

class GetPaidFailed extends FundRequestState {
  final String message;

  const GetPaidFailed(this.message);

  @override
  List<Object> get props => [message];
}


class GetModulePayLoading extends FundRequestState {
}

class GetModulePaySuccess extends FundRequestState {

  final List<String> groups;

  const GetModulePaySuccess(this.groups);

  @override
  List<Object> get props => [groups];
}

class GetModulePayError extends FundRequestState {
  final String message;

  const GetModulePayError(this.message);

  @override
  List<Object> get props => [message];
}