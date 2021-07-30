part of 'edit_mode_cubit.dart';

abstract class EditModeState extends Equatable {
  const EditModeState();

  @override
  List<Object?> get props => [];
}

class EditModeDisabled extends EditModeState {}

class EditModeEnabled extends EditModeState {
  final String chat;
  final Message message;
  final bool? lastMessage;

  EditModeEnabled({
    required this.chat,
    required this.message,
    this.lastMessage = false,
  });

  @override
  List<Object?> get props => [
        chat,
        message,
        lastMessage,
      ];
}
