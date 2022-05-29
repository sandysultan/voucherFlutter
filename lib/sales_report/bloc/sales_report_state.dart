part of 'sales_report_bloc.dart';

abstract class SalesReportState extends Equatable {
  const SalesReportState();
  @override
  List<Object> get props => [];
}

class SalesReportInitial extends SalesReportState {
}

class GetGroupLoading extends SalesReportState {
}

class GetGroupSuccess extends SalesReportState {
  final List<String> group;

  const GetGroupSuccess(this.group);

  @override
  List<Object> get props => [group];
}

class GetGroupFailed extends SalesReportState {
  final String message;

  const GetGroupFailed(this.message);

  @override
  List<Object> get props => [message];
}


class SalesLoading extends SalesReportState {
}

class SalesLoaded extends SalesReportState {
  final List<Kiosk> kiosks;
  final Map<Kiosk,int> totalCashMap;
  final int totalCash;

  const SalesLoaded(this.kiosks,this.totalCashMap, this.totalCash);

  @override
  List<Object> get props => [kiosks,totalCashMap];
}


class SalesEmpty extends SalesReportState {
  final String message;

  const SalesEmpty(this.message);

  @override
  List<Object> get props => [message];

}
