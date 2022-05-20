part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {
}

class RoleLoaded extends HomeState {
  final List<Role> roles;
  final List<Group> groups;

  const RoleLoaded(this.roles,this.groups);

  @override
  List<Object> get props => [roles,groups];
}

class EmptyRole extends HomeState {

}

class AppBarClicked extends HomeState {

  final int idAction;

  const AppBarClicked(this.idAction);

  @override
  List<Object> get props => [idAction];
}
