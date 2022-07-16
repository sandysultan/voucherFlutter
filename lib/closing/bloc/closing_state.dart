part of 'closing_bloc.dart';

abstract class ClosingState extends Equatable {
  const ClosingState();
  @override
  List<Object> get props => [];
}

class ClosingInitial extends ClosingState {
}


class GetGroupLoading extends ClosingState {
}

class GetGroupSuccess extends ClosingState {
  final List<String> group;

  const GetGroupSuccess(this.group);

  @override
  List<Object> get props => [group];
}

class GetGroupFailed extends ClosingState {
  final String message;

  const GetGroupFailed(this.message);

  @override
  List<Object> get props => [message];
}



class GetStatusLoading extends ClosingState {
}

class GetStatusSuccess extends ClosingState {
  final String groupName;
  final StatusClosingResponse response;

  const GetStatusSuccess(this.groupName,this.response);

  @override
  List<Object> get props => [groupName,response];
}

class GetStatusFailed extends ClosingState {
  final String message;

  const GetStatusFailed(this.message);

  @override
  List<Object> get props => [message];
}

class CloseLoading extends ClosingState {
}

class CloseSuccess extends ClosingState {

}

class CloseFailed extends ClosingState {
  final String message;

  const CloseFailed(this.message);

  @override
  List<Object> get props => [message];
}
