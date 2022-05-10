part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadRolesAndGroups extends HomeEvent {
  final String email;
  const LoadRolesAndGroups(this.email);

  @override
  List<Object?> get props => [email];
}
