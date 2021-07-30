part of 'user_status_cubit.dart';

abstract class UserStatusState extends Equatable {
  const UserStatusState();

  @override
  List<Object?> get props => [];
}

class UpdatedUserStatusState extends UserStatusState {
  final User user;

  UpdatedUserStatusState(this.user);

  @override
  List<Object?> get props => [user];
}

class ErrorUserStatusState extends UserStatusState {}
