part of 'sales_bloc.dart';

abstract class SalesState extends Equatable {
  const SalesState();
  @override
  List<Object> get props => [];
}

class SalesInitial extends SalesState {
  @override
  List<Object> get props => [];
}

class SalesLoaded extends SalesState {
  final List<Kiosk> kiosks;

  const SalesLoaded(this.kiosks);

  @override
  List<Object> get props => [kiosks];
}

class SalesListLoaded extends SalesState {
  final List<Sales> sales;
  final bool isLast;

  const SalesListLoaded(this.sales,this.isLast);

  @override
  List<Object> get props => [sales];
}

class SalesLoading extends SalesState {
}

class SalesEmpty extends SalesState {
}

class GetGroupLoading extends SalesState {
}

class GetGroupSuccess extends SalesState {
  final List<String> group;

  const GetGroupSuccess(this.group);

  @override
  List<Object> get props => [group];
}

class GetGroupFailed extends SalesState {
  final String message;

  const GetGroupFailed(this.message);

  @override
  List<Object> get props => [message];
}

class GetOperatorsLoading extends SalesState {
}

class GetOperatorsSuccess extends SalesState {
  final List<repository.User> operators;

  const GetOperatorsSuccess(this.operators);

  @override
  List<Object> get props => [operators];
}

class GetOperatorsFailed extends SalesState {
  final String message;

  const GetOperatorsFailed(this.message);

  @override
  List<Object> get props => [message];
}

class DeleteSalesLoading extends SalesState {
}

class DeleteSalesSuccess extends SalesState {
}

class DeleteSalesFailed extends SalesState {
  final String message;

  const DeleteSalesFailed(this.message);

  @override
  List<Object> get props => [message];
}


