part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {
}

class RoleLoaded extends HomeState {
  final List<String> modules;


  const RoleLoaded(this.modules);

  @override
  List<Object> get props => [modules];
}

class EmptyRole extends HomeState {
  final String message;


  const EmptyRole(this.message);

  @override
  List<Object> get props => [message];

}

class AppBarClicked extends HomeState {

  final int idAction;

  const AppBarClicked(this.idAction);

  @override
  List<Object> get props => [idAction];
}
