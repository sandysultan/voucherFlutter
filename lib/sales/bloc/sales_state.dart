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

  const SalesListLoaded(this.sales);

  @override
  List<Object> get props => [sales];
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


