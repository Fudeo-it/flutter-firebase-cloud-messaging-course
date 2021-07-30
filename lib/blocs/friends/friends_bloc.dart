import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:telegram_app/models/friend.dart';
import 'package:telegram_app/repositories/friend_repository.dart';

part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FriendRepository friendRepository;

  FriendsBloc({required this.friendRepository}) : super(FetchingFriendsState());

  @override
  Stream<FriendsState> mapEventToState(
    FriendsEvent event,
  ) async* {
    if (event is FetchFriendsEvent) {
      yield FetchingFriendsState();

      List<Friend>? friends;
      try {
        friends = await friendRepository.friends(event.uid);
      } catch (exception) {
        yield ErrorFriendsState();
      }

      if (friends != null) {
        yield friends.isEmpty ? NoFriendsState() : FetchedFriendsState(friends);
      }
    }
  }

  void fetchFriends(String uid) => add(FetchFriendsEvent(uid));
}
