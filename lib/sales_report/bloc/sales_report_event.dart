part of 'sales_report_bloc.dart';

abstract class SalesReportEvent extends Equatable {
  const SalesReportEvent();

  @override
  List<Object?> get props => [];
}


class GetGroups extends SalesReportEvent{

  const GetGroups();

}


class SalesRefresh extends SalesReportEvent{
  final String groupName;
  final int? year;
  final int? month;

  const SalesRefresh({required this.groupName, this.year, this.month});

  @override
  List<Object?> get props => [groupName,if(year!=null)...[year],if(month!=null)...[month]];

}
