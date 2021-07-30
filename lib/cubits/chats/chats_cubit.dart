import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:telegram_app/models/chat.dart';
import 'package:telegram_app/repositories/chat_repository.dart';

part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  final String uid;
  final ChatRepository chatRepository;

  StreamSubscription<List<Chat>>? _streamSubscription;

  ChatsCubit(this.uid, {required this.chatRepository})
      : super(FetchingChatsState()) {
    _streamSubscription = chatRepository.chats(uid).listen(
          (chats) => emit(
            chats.isEmpty ? NoChatsState() : FetchedChatsState(chats),
          ),
          onError: (_) => emit(ErrorChatsState()),
        );
  }

  @override
  Future<void> close() async {
    await _streamSubscription?.cancel();
    return super.close();
  }
}
