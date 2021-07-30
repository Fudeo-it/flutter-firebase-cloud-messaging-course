part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class FindChatEvent extends ChatEvent {
  final String user;
  final String other;

  FindChatEvent({
    required this.user,
    required this.other,
  });

  @override
  List<Object?> get props => [
        user,
        other,
      ];
}

class CreateChatEvent extends FindChatEvent {
  final String message;

  CreateChatEvent({
    required String user,
    required String other,
    required this.message,
  }) : super(
          user: user,
          other: other,
        );

  @override
  List<Object?> get props => [
        ...super.props,
        message,
      ];
}

class SendMessageEvent extends CreateChatEvent {
  final String chat;
  final File? attachment;

  SendMessageEvent(
    this.chat, {
    required String user,
    required String other,
    required String message,
    this.attachment,
  }) : super(
          user: user,
          other: other,
          message: message,
        );

  @override
  List<Object?> get props => [
        ...super.props,
        chat,
        attachment,
      ];
}

class DeleteChatEvent extends ChatEvent {
  final String id;
  final StreamSubscription? streamSubscription;

  DeleteChatEvent(
    this.id, {
    this.streamSubscription,
  });

  @override
  List<Object?> get props => [id, streamSubscription];
}

class NewMessagesEvent extends ChatEvent {
  final Chat chat;
  final List<Message> messages;
  final StreamSubscription? streamSubscription;

  NewMessagesEvent(
    this.chat, {
    this.messages = const [],
    this.streamSubscription,
  });

  @override
  List<Object?> get props => [
        chat,
        messages,
        streamSubscription,
      ];
}

class EmitErrorChatEvent extends ChatEvent {
  final StreamSubscription? streamSubscription;

  EmitErrorChatEvent(this.streamSubscription);

  @override
  List<Object?> get props => [streamSubscription];
}

class UpdateMessageEvent extends ChatEvent {
  final String id;
  final String chat;
  final String message;
  final bool lastMessage;

  UpdateMessageEvent(
    this.id, {
    required this.chat,
    required this.message,
    this.lastMessage = false,
  });

  @override
  List<Object?> get props => [
        id,
        chat,
        message,
        lastMessage,
      ];
}

class DeleteMessageEvent extends ChatEvent {
  final String chat;
  final String message;
  final String? lastMessage;

  DeleteMessageEvent(
    this.message, {
    required this.chat,
    this.lastMessage,
  });

  @override
  List<Object?> get props => [
        message,
        chat,
        lastMessage,
      ];
}
