part of 'transfer_report_bloc.dart';

abstract class TransferReportEvent extends Equatable {
  const TransferReportEvent();

  @override
  List<Object?> get props => [];
}


class GetGroups extends TransferReportEvent{

  const GetGroups();

}


class TransferRefresh extends TransferReportEvent{
  final String groupName;
  final int year;
  final int month;

  const TransferRefresh({required this.groupName, required this.year, required this.month});

  @override
  List<Object?> get props => [groupName,year,month];

}
