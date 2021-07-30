import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_essentials_kit/misc/two_way_binding.dart';
import 'package:path/path.dart' as path;
import 'package:telegram_app/blocs/friend_status/friend_status_bloc.dart';
import 'package:telegram_app/models/chat.dart';
import 'package:telegram_app/models/message.dart';
import 'package:telegram_app/repositories/chat_repository.dart';
import 'package:telegram_app/repositories/message_repository.dart';

part 'chat_event.dart';

part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FriendStatusBloc friendStatusBloc;
  final ChatRepository chatRepository;
  final MessageRepository messageRepository;

  final messageBinding = TwoWayBinding<String>();

  Stream<bool> get emptyChat => messageBinding.stream
      .map((message) => message == null || message.isEmpty);

  ChatBloc({
    required this.friendStatusBloc,
    required this.chatRepository,
    required this.messageRepository,
  }) : super(FetchingChatState());

  @override
  Stream<ChatState> mapEventToState(
    ChatEvent event,
  ) async* {
    if (event is SendMessageEvent) {
      yield* _mapSendMessageEventToState(event);
    } else if (event is CreateChatEvent) {
      yield* _mapCreateChatEventToState(event);
    } else if (event is FindChatEvent) {
      yield* _mapFindChatEventToState(event);
    } else if (event is DeleteChatEvent) {
      yield* _mapDeleteChatEventToState(event);
    } else if (event is NewMessagesEvent) {
      yield* _mapNewMessagesEventToState(event);
    } else if (event is EmitErrorChatEvent) {
      yield* _mapEmitErrorChatEventToState(event);
    } else if (event is UpdateMessageEvent) {
      yield* _mapUpdateMessageEventToState(event);
    } else if (event is DeleteMessageEvent) {
      yield* _mapDeleteMessageEventToState(event);
    }
  }

  Stream<ChatState> _mapSendMessageEventToState(SendMessageEvent event) async* {
    try {
      if (!friendStatusBloc.friends) {
        friendStatusBloc.createFriendship(
          me: event.user,
          user: event.other,
        );
      }

      await messageRepository.send(
        event.chat,
        sender: event.user,
        message: event.message,
        attachment: event.attachment,
      );

      await chatRepository.update(
        chat: event.chat,
        lastMessage: event.attachment != null
            ? path.basenameWithoutExtension(event.attachment!.path)
            : event.message,
      );
    } catch (error) {
      yield ErrorChatState();
    }
  }

  Stream<ChatState> _mapCreateChatEventToState(CreateChatEvent event) async* {
    Chat? chat;
    try {
      chat = await chatRepository.create(
        me: event.user,
        other: event.other,
        message: event.message,
      );
    } catch (error) {
      yield ErrorChatState();
    }

    if (chat != null) {
      add(
        SendMessageEvent(
          chat.id!,
          user: event.user,
          other: event.other,
          message: event.message,
        ),
      );

      yield* _subscribeForIncomingMessages(chat);
    }
  }

  Stream<ChatState> _mapFindChatEventToState(FindChatEvent event) async* {
    yield FetchingChatState();

    List<Chat>? chats;
    try {
      chats = await chatRepository.find(
        event.user,
        other: event.other,
      );
    } catch (error) {
      yield ErrorChatState();
    }

    if (chats != null) {
      if (chats.length == 1) {
        yield* _subscribeForIncomingMessages(chats.first);
      } else if (chats.isEmpty) {
        yield NoChatAvailableState();
      } else {
        yield ErrorChatState();
      }
    }
  }

  Stream<ChatState> _mapDeleteChatEventToState(DeleteChatEvent event) async* {
    bool success = true;

    await event.streamSubscription?.cancel();

    try {
      await chatRepository.delete(event.id);
      await messageRepository.clean(event.id);
    } catch (error) {
      success = false;
      yield ErrorChatState();
    } finally {
      if (success) {
        yield NoChatAvailableState();
      }
    }
  }

  Stream<ChatState> _subscribeForIncomingMessages(Chat chat) async* {
    StreamSubscription? streamSubscription;
    streamSubscription = messageRepository.messages(chat.id!).listen(
        (messages) => add(
              NewMessagesEvent(
                chat,
                streamSubscription: streamSubscription,
                messages: messages,
              ),
            ),
        onError: (_) => add(EmitErrorChatEvent(streamSubscription)));

    yield ChatAvailableState(chat);
  }

  Stream<ChatState> _mapNewMessagesEventToState(NewMessagesEvent event) async* {
    yield ChatWithMessagesState(
      event.chat,
      streamSubscription: event.streamSubscription,
      messages: event.messages,
    );
  }

  Stream<ChatState> _mapEmitErrorChatEventToState(
      EmitErrorChatEvent event) async* {
    await event.streamSubscription?.cancel();

    yield ErrorChatState();
  }

  Stream<ChatState> _mapUpdateMessageEventToState(
      UpdateMessageEvent event) async* {
    try {
      await messageRepository.update(
        event.id,
        chat: event.chat,
        message: event.message,
      );

      if (event.lastMessage) {
        await chatRepository.update(
          chat: event.chat,
          lastMessage: event.message,
        );
      }
    } catch (error) {
      yield ErrorChatState();
    }
  }

  Stream<ChatState> _mapDeleteMessageEventToState(
      DeleteMessageEvent event) async* {
    try {
      await messageRepository.delete(
        chat: event.chat,
        message: event.message,
      );

      if (event.lastMessage != null) {
        await chatRepository.update(
          chat: event.chat,
          lastMessage: event.lastMessage,
        );
      }
    } catch (error) {
      yield ErrorChatState();
    }
  }

  void findChat({
    required String user,
    required String other,
  }) =>
      add(FindChatEvent(user: user, other: other));

  void sendMessage({
    required String user,
    required String other,
    String? chat,
    String? message,
    File? attachment,
  }) {
    add((state is ChatAvailableState)
        ? SendMessageEvent(
            chat ?? (state as ChatAvailableState).chat.id!,
            user: user,
            other: other,
            message: message ?? messageBinding.value ?? '',
            attachment: attachment,
          )
        : CreateChatEvent(
            user: user,
            other: other,
            message: message ?? messageBinding.value ?? '',
          ));

    messageBinding.value = '';
  }

  void deleteChat(String id, {StreamSubscription? streamSubscription}) => add(
        DeleteChatEvent(
          id,
          streamSubscription: streamSubscription,
        ),
      );

  void updateMessage(
    String id, {
    required String chat,
    String? message,
    bool lastMessage = false,
  }) =>
      add(
        UpdateMessageEvent(
          id,
          chat: chat,
          message: message ?? messageBinding.value ?? '',
          lastMessage: lastMessage,
        ),
      );

  void deleteMessage(
    String message, {
    required String chat,
    String? lastMessage,
  }) =>
      add(
        DeleteMessageEvent(
          message,
          chat: chat,
          lastMessage: lastMessage,
        ),
      );

  @override
  Future<void> close() async {
    if (state is ChatAvailableState) {
      await (state as ChatAvailableState).streamSubscription?.cancel();
    }

    await messageBinding.close();

    return super.close();
  }
}
