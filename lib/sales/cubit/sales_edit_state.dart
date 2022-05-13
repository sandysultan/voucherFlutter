part of 'sales_edit_cubit.dart';

abstract class SalesEditState extends Equatable {
  const SalesEditState();
  @override
  List<Object> get props => [];
}

class SalesEditInitial extends SalesEditState {
}
class SalesEditLoading extends SalesEditState {
}
class SalesEditSaved extends SalesEditState {
  final Sales sale;
  const SalesEditSaved(this.sale);
  @override
  List<Object> get props => [sale];

}
class SalesEditError extends SalesEditState {
  final String message;
  const SalesEditError(this.message);

  @override
  List<Object> get props => [message];
}
