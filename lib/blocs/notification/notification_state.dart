part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NoNotificationState extends NotificationState {

}

class AvailableNotificationState extends NotificationState {
  final Chat chat;

  AvailableNotificationState(this.chat);

  @override
  List<Object> get props => [chat];
}