part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadRolesAndGroups extends HomeEvent {
  final String uid;
  const LoadRolesAndGroups(this.uid);

  @override
  List<Object?> get props => [uid];
}

class AppbarAction extends HomeEvent {
  final int id;
  const AppbarAction(this.id);

  @override
  List<Object?> get props => [id];
}
