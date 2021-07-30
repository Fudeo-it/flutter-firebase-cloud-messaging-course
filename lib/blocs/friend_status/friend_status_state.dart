part of 'friend_status_bloc.dart';

abstract class FriendStatusState extends Equatable {
  const FriendStatusState();

  @override
  List<Object?> get props => [];
}

class FetchingFriendStatusState extends FriendStatusState {}

class FetchedFriendStatusState extends FriendStatusState {
  final bool friends;

  FetchedFriendStatusState(this.friends);

  @override
  List<Object?> get props => [friends];
}

class ErrorFriendStatusState extends FriendStatusState {}