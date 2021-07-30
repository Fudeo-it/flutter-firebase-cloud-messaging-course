part of 'chats_cubit.dart';

abstract class ChatsState extends Equatable {
  const ChatsState();

  @override
  List<Object?> get props => [];
}

class FetchingChatsState extends ChatsState {}

class FetchedChatsState extends ChatsState {
  final List<Chat> chats;

  FetchedChatsState(this.chats);

  @override
  List<Object?> get props => [chats];
}

class NoChatsState extends ChatsState {}

class ErrorChatsState extends ChatsState {}