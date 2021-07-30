part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class CheckNotificationEvent extends NotificationEvent {}

class EmitNotificationEvent extends NotificationEvent {
  final Map<String, dynamic> payload;

  EmitNotificationEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}
