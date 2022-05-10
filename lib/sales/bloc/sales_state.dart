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

class SalesEmpty extends SalesState {
}
