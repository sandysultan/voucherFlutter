part of 'sales_bloc.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();

  @override
  List<Object?> get props => [];
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


class GetGroups extends SalesEvent{

  const GetGroups();

}

class GetLastClosing extends SalesEvent{

  final String groupName;
  const GetLastClosing({required this.groupName});

  @override
  List<Object?> get props => [groupName];
}


class GetOperator extends SalesEvent{
  final String groupName;

  const GetOperator({required this.groupName});

  @override
  List<Object?> get props => [groupName];
}

class DeleteSales extends SalesEvent{
  final int id;
  final List<Sales> sales;

  const DeleteSales({required this.id,required this.sales});

  @override
  List<Object?> get props => [id,sales];
}
