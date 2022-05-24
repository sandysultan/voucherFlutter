part of 'sales_bloc.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();
}

class SalesRefresh extends SalesEvent{
  final String groupName;

  final int? status;

  const SalesRefresh(this.groupName,this.status);

  @override
  List<Object?> get props => [groupName,if(status!=null)...[status]];

}

class SalesListRefresh extends SalesEvent{
  final int kioskId;
  final int year;
  final int? month;

  const SalesListRefresh({required this.kioskId,required this.year,this.month});

  @override
  List<Object?> get props => [kioskId,year,month];

}