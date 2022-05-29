part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadModules extends HomeEvent {
  final String uid;
  const LoadModules(this.uid);

  @override
  List<Object?> get props => [uid];
}

class AppbarAction extends HomeEvent {
  final int id;
  const AppbarAction(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateFCM extends HomeEvent {
  final String? fcm;
  const UpdateFCM(this.fcm);

  @override
  List<Object?> get props => [fcm];
}
