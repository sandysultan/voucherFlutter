part of 'sales_edit_save_cubit.dart';

abstract class SalesEditSaveState extends Equatable {
  const SalesEditSaveState();
  @override
  List<Object> get props => [];
}

class SalesEditSaveInitial extends SalesEditSaveState {
}
class SalesEditSaveLoading extends SalesEditSaveState {
}
class SalesEditSaved extends SalesEditSaveState {
  final Sales sale;
  const SalesEditSaved(this.sale);
  @override
  List<Object> get props => [sale];

}
class SalesEditError extends SalesEditSaveState {
  final String message;
  const SalesEditError(this.message);

  @override
  List<Object> get props => [message];
}
