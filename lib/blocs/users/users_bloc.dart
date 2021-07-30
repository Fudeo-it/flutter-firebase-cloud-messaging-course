import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:telegram_app/cubits/search_cubit.dart';
import 'package:telegram_app/models/user.dart';
import 'package:telegram_app/repositories/user_repository.dart';

part 'users_event.dart';

part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final SearchCubit searchCubit;
  final UserRepository userRepository;

  StreamSubscription<String?>? _searchStreamSubscription;
  StreamSubscription<bool>? _toggleStreamSubscription;

  Timer? _debounce;

  UsersBloc({
    required this.searchCubit,
    required this.userRepository,
  }) : super(InitialUsersState()) {
    _searchStreamSubscription = searchCubit.searchBinding.stream
        .where((query) => query != null)
        .listen((query) {
      if (_debounce != null && _debounce!.isActive) _debounce?.cancel();
      _debounce =
          Timer(const Duration(milliseconds: 250), () => _searchUsers(query!));
    });

    _toggleStreamSubscription =
        searchCubit.stream.where((enabled) => !enabled).listen((_) => _reset());
  }

  @override
  Stream<UsersState> mapEventToState(
    UsersEvent event,
  ) async* {
    if (event is SearchUsersEvent) {
      yield SearchingUsersState();

      List<User>? users;
      try {
        users = await userRepository.search(event.query);
      } catch (exception) {
        yield ErrorUsersState();
      }

      if (users != null) {
        yield users.isEmpty ? NoUsersState() : FetchedUsersState(users);
      }
    } else if (event is ResetSearchEvent) {
      yield InitialUsersState();
    }
  }

  @override
  Future<void> close() async {
    await _searchStreamSubscription?.cancel();
    await _toggleStreamSubscription?.cancel();

    return super.close();
  }

  void _searchUsers(String query) => add(SearchUsersEvent(query));

  void _reset() => add(ResetSearchEvent());
}
