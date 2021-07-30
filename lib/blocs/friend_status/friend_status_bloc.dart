import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:telegram_app/repositories/friend_repository.dart';

part 'friend_status_event.dart';

part 'friend_status_state.dart';

class FriendStatusBloc extends Bloc<FriendStatusEvent, FriendStatusState> {
  final FriendRepository friendRepository;

  FriendStatusBloc({
    required this.friendRepository,
  }) : super(FetchingFriendStatusState());

  bool get friends => state is FetchedFriendStatusState &&
      (state as FetchedFriendStatusState).friends;

  @override
  Stream<FriendStatusState> mapEventToState(
    FriendStatusEvent event,
  ) async* {
    if (event is FetchFriendStatusEvent) {
      yield* _mapFetchFriendStatusEventToState(event);
    } else if (event is CreateFriendshipEvent) {
      yield* _mapCreateFriendshipEventToState(event);
    }
  }

  Stream<FriendStatusState> _mapFetchFriendStatusEventToState(
      FetchFriendStatusEvent event) async* {
    yield FetchingFriendStatusState();

    bool? friends;
    try {
      friends = await friendRepository.isFriend(
        me: event.me,
        user: event.user,
      );
    } catch (error) {
      yield ErrorFriendStatusState();
    }

    if (friends != null) {
      yield FetchedFriendStatusState(friends);
    }
  }

  Stream<FriendStatusState> _mapCreateFriendshipEventToState(
      CreateFriendshipEvent event) async* {
    yield FetchingFriendStatusState();

    try {
      await friendRepository.create(
        me: event.me,
        user: event.user,
      );
      yield FetchedFriendStatusState(true);
    } catch (error) {
      yield ErrorFriendStatusState();
    }
  }

  void createFriendship({
    required String me,
    required String user,
  }) =>
      add(
        CreateFriendshipEvent(
          me: me,
          user: user,
        ),
      );

  void fetchStatus({
    required String me,
    required String user,
  }) =>
      add(
        FetchFriendStatusEvent(
          me: me,
          user: user,
        ),
      );
}
