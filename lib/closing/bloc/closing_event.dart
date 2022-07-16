part of 'closing_bloc.dart';

abstract class ClosingEvent extends Equatable {
  const ClosingEvent();
  @override
  List<Object?> get props => [];
}

class GetGroups extends ClosingEvent{
}


class GetStatus extends ClosingEvent{
  final String groupName;

  const GetStatus({required this.groupName});

  @override
  List<Object?> get props => [groupName];

}

class Close extends ClosingEvent{
  final String groupName;

  const Close({required this.groupName});

  @override
  List<Object?> get props => [groupName];
}
