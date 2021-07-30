part of 'friends_bloc.dart';

abstract class FriendsEvent extends Equatable {
  const FriendsEvent();
}

class FetchFriendsEvent extends FriendsEvent {
  final String uid;

  FetchFriendsEvent(this.uid);

  @override
  List<Object?> get props => [uid];
}