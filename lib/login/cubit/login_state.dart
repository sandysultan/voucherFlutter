part of 'login_cubit.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class LoginInitial extends LoginState {
  @override
  List<Object> get props => [];
}

class LoginLoading extends LoginState {
  final String message;

  const LoginLoading(this.message);

  @override
  List<Object> get props => [];
}

class LoginSuccess extends LoginState {
  final String token;
  final String email;
  const LoginSuccess({required this.token, required this.email});

  @override
  List<Object> get props => [token];
}


class LoginFailed extends LoginState {
  final String failedMessage;

  const LoginFailed(this.failedMessage);

  @override
  List<Object> get props => [failedMessage];
}

