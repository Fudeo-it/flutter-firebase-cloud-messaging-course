part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class FetchingChatState extends ChatState {}

class NoChatAvailableState extends ChatState {}

class ChatAvailableState extends ChatState {
  final Chat chat;
  final StreamSubscription? streamSubscription;

  ChatAvailableState(this.chat, {this.streamSubscription});

  @override
  List<Object?> get props => [chat, streamSubscription];
}

class ChatWithMessagesState extends ChatAvailableState {
  final List<Message> messages;

  ChatWithMessagesState(
    Chat chat, {
    this.messages = const [],
    StreamSubscription? streamSubscription,
  }) : super(
          chat,
          streamSubscription: streamSubscription,
        );

  @override
  List<Object?> get props => [
        ...super.props,
        messages,
      ];
}

class ErrorChatState extends ChatState {}
