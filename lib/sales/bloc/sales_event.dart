part of 'sales_bloc.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();
}

class SalesRefresh extends SalesEvent{
  final String groupName;

  const SalesRefresh(this.groupName);

  @override
  List<Object?> get props => [groupName];

}