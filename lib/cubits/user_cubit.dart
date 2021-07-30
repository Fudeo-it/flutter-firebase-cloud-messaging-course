import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:telegram_app/blocs/chat/chat_bloc.dart';
import 'package:telegram_app/repositories/user_repository.dart';

class UserCubit extends Cubit<void> {
  final String uid;
  final UserRepository userRepository;
  final ChatBloc chatBloc;

  StreamSubscription<ChatState>? _streamSubscription;
  Timer? _debounce;

  UserCubit(
    this.uid, {
    required this.userRepository,
    required this.chatBloc,
  }) : super(null) {
    _streamSubscription = chatBloc.stream.listen((_) {
      if (_debounce != null && _debounce!.isActive) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 250),
          () async => await userRepository.update(uid));
    });
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    await _streamSubscription?.cancel();

    return super.close();
  }
}
