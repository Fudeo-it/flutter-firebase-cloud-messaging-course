part of 'friends_bloc.dart';

abstract class FriendsState extends Equatable {
  const FriendsState();

  @override
  List<Object?> get props => [];
}

class FetchingFriendsState extends FriendsState{}

class FetchedFriendsState extends FriendsState {
  final List<Friend> friends;

  FetchedFriendsState(this.friends);

  @override
  List<Object?> get props => [friends];
}

class NoFriendsState extends FriendsState {}

class ErrorFriendsState extends FriendsState {}