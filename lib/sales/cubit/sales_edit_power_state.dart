part of 'sales_edit_power_cubit.dart';

abstract class SalesEditPowerState extends Equatable {
  const SalesEditPowerState();
  @override
  List<Object> get props => [];
}

class SalesEditPowerInitial extends SalesEditPowerState {
}

class SalesEditPowerLoading extends SalesEditPowerState {
}

class SalesEditPowerSuccess extends SalesEditPowerState {
  final Sales sales;
  const SalesEditPowerSuccess(this.sales);

  @override
  List<Object> get props => [sales];
}

class SalesEditPowerError extends SalesEditPowerState {
  final String message;
  const SalesEditPowerError(this.message);
  @override
  List<Object> get props => [message];
}
