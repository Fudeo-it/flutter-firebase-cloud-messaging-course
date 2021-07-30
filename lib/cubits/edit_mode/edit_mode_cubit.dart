import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:telegram_app/blocs/chat/chat_bloc.dart';
import 'package:telegram_app/models/message.dart';

part 'edit_mode_state.dart';

class EditModeCubit extends Cubit<EditModeState> {
  final ChatBloc chatBloc;

  EditModeCubit({required this.chatBloc}) : super(EditModeDisabled());

  @override
  void onChange(Change<EditModeState> change) {
    if (change.nextState is EditModeEnabled) {
      chatBloc.messageBinding.value =
          (change.nextState as EditModeEnabled).message.message;
    } else if (change.nextState is EditModeDisabled) {
      chatBloc.messageBinding.value = '';
    }

    super.onChange(change);
  }

  void enableEditMode({
    required String chat,
    required Message message,
    bool lastMessage = false,
  }) =>
      emit(
        EditModeEnabled(
          chat: chat,
          message: message,
          lastMessage: lastMessage,
        ),
      );

  void disableEditMode() => emit(EditModeDisabled());
}
