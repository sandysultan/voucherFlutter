part of 'sales_edit_power_cubit.dart';

abstract class SalesEditPowerState extends Equatable {
  const SalesEditPowerState();
  @override
  List<Object> get props => [];
}

class SalesEditPowerInitial extends SalesEditPowerState {
}

class SalesEditGetPowerLoading extends SalesEditPowerState {
}

class SalesEditGetPowerSuccess extends SalesEditPowerState {
  final Sales? sales;
  const SalesEditGetPowerSuccess(this.sales);

  @override
  List<Object> get props => sales!=null?[sales!]:[];
}

class SalesEditPowerError extends SalesEditPowerState {
  final String message;
  const SalesEditPowerError(this.message);
  @override
  List<Object> get props => [message];
}



class SalesEditUpdatePowerLoading extends SalesEditPowerState {
}

class SalesEditUpdatePowerSuccess extends SalesEditPowerState {
  final Kiosk kiosk;
  const SalesEditUpdatePowerSuccess(this.kiosk);

  @override
  List<Object> get props => [kiosk];
}


class SalesEditUpdatePowerError extends SalesEditPowerState {
  final String message;
  const SalesEditUpdatePowerError(this.message);
  @override
  List<Object> get props => [message];
}