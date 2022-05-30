part of 'transfer_report_bloc.dart';

abstract class TransferReportState extends Equatable {
  const TransferReportState();
  @override
  List<Object> get props => [];
}

class TransferReportInitial extends TransferReportState {
}

class GetGroupLoading extends TransferReportState {
}

class GetGroupSuccess extends TransferReportState {
  final List<String> group;

  const GetGroupSuccess(this.group);

  @override
  List<Object> get props => [group];
}

class GetGroupFailed extends TransferReportState {
  final String message;

  const GetGroupFailed(this.message);

  @override
  List<Object> get props => [message];
}

class TransferLoading extends TransferReportState {
}

class TransferLoaded extends TransferReportState {
  final List<Transfer> transfers;

  const TransferLoaded(this.transfers);

  @override
  List<Object> get props => [transfers];
}


class TransferEmpty extends TransferReportState {
  final String message;

  const TransferEmpty(this.message);

  @override
  List<Object> get props => [message];

}
