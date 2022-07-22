part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {
}

class GetUserLoading extends UserState {
}

class GetUserSuccess extends UserState {
  final List<rep.User> users;

  const GetUserSuccess(this.users);

  @override
  List<Object> get props => [users];
}

class GetUserFailed extends UserState {
  final String message;

  const GetUserFailed(this.message);

  @override
  List<Object> get props => [message];
}

