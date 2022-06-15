part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {
}


class NotificationLoading extends NotificationState {
}

class NotificationLoaded extends NotificationState {
  final List<Notification> notifications;

  const NotificationLoaded(this.notifications);

  @override
  List<Object> get props => [notifications];
}

class NotificationEmpty extends NotificationState {
  final String message;

  const NotificationEmpty(this.message);

  @override
  List<Object> get props => [message];

}
