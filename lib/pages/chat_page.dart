import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_essentials_kit/flutter_essentials_kit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:telegram_app/blocs/chat/chat_bloc.dart';
import 'package:telegram_app/blocs/friend_status/friend_status_bloc.dart';
import 'package:telegram_app/blocs/image_picker/image_picker_bloc.dart';
import 'package:telegram_app/cubits/edit_mode/edit_mode_cubit.dart';
import 'package:telegram_app/cubits/user_cubit.dart';
import 'package:telegram_app/cubits/user_status/user_status_cubit.dart';
import 'package:telegram_app/mixin/attachment_mixin.dart';
import 'package:telegram_app/models/chat.dart';
import 'package:telegram_app/models/message.dart';
import 'package:telegram_app/models/user.dart' as models;
import 'package:telegram_app/router/app_router.gr.dart';
import 'package:telegram_app/widgets/connectivity_widget.dart';
import 'package:telegram_app/widgets/message_widget.dart';
import 'package:telegram_app/widgets/shimmed_list.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatPage extends ConnectivityWidget
    with AttachmentMixin
    implements AutoRouteWrapper {
  final User user;
  final models.User other;

  ChatPage({
    Key? key,
    required this.user,
    required this.other,
  }) : super(key: key);

  @override
  Widget wrappedRoute(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => UserStatusCubit(
              other,
              userRepository: context.read(),
            ),
          ),
          BlocProvider(
            create: (context) => FriendStatusBloc(
              friendRepository: context.read(),
            )..fetchStatus(
                me: user.uid,
                user: other.id!,
              ),
          ),
          BlocProvider(
            create: (context) => ChatBloc(
              friendStatusBloc: context.read(),
              chatRepository: context.read(),
              messageRepository: context.read(),
            )..findChat(
                user: user.uid,
                other: other.id!,
              ),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => UserCubit(
              user.uid,
              userRepository: context.read(),
              chatBloc: context.read(),
            ),
          ),
          BlocProvider(
            create: (context) => EditModeCubit(
              chatBloc: context.read(),
            ),
          ),
          BlocProvider(
            create: (context) => ImagePickerBloc(
              imagePickerService: context.read(),
            ),
          ),
        ],
        child: this,
      );

  @override
  Widget connectedBuild(BuildContext context) =>
      BlocListener<ImagePickerBloc, ImagePickerState>(
        listener: (context, state) {
          _shouldOpenAttachmentPage(context, state: state);
        },
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) =>
              BlocBuilder<EditModeCubit, EditModeState>(
            builder: (context, editModeState) => Scaffold(
              appBar: _appBar(
                context,
                chatState: state,
                editModeState: editModeState,
              ),
              body: _body(
                context,
                state: state,
              ),
            ),
          ),
        ),
      );

  PreferredSizeWidget _appBar(
    BuildContext context, {
    required ChatState chatState,
    required EditModeState editModeState,
  }) =>
      AppBar(
        leading: editModeState is EditModeEnabled
            ? CloseButton(
                onPressed: () =>
                    context.read<EditModeCubit>().disableEditMode(),
              )
            : null,
        backgroundColor:
            editModeState is EditModeEnabled ? Colors.black87 : null,
        title: editModeState is EditModeEnabled
            ? Text(AppLocalizations.of(context)?.title_edit_message ?? '')
            : BlocConsumer<UserStatusCubit, UserStatusState>(
                listener: (context, state) {
                  _shouldShowErrorSnackbar(context, state: state);
                },
                builder: (context, state) => Row(
                  children: [
                    _otherAvatar(),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _otherName(
                            context,
                            other: state is UpdatedUserStatusState
                                ? state.user
                                : other,
                          ),
                          _otherLastAccess(
                            context,
                            other: state is UpdatedUserStatusState
                                ? state.user
                                : other,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        actions: editModeState is EditModeDisabled
            ? () {
                final items = [
                  if (chatState is ChatAvailableState)
                    PopupMenuItem<_AppBarMenuActions>(
                      child: Text(
                        AppLocalizations.of(context)?.action_delete_chat ?? '',
                      ),
                      value: _AppBarMenuActions.ACTION_DELETE,
                    ),
                ];

                return items.isNotEmpty
                    ? [
                        PopupMenuButton<_AppBarMenuActions>(
                          icon: Icon(Icons.more_vert),
                          itemBuilder: (_) => items,
                          onSelected: (action) {
                            if (_AppBarMenuActions.ACTION_DELETE == action) {
                              _showDeleteChatDialog(
                                context,
                                state: chatState as ChatAvailableState,
                              );
                            }
                          },
                        )
                      ]
                    : null;
              }()
            : null,
      );

  Widget _body(BuildContext context, {required ChatState state}) => Column(
        children: [
          _messagesBody(chatState: state),
          if (state is! ErrorChatState)
            _footer(context, disabled: state is FetchingChatState),
        ],
      );

  Widget _messagesBody({required ChatState chatState}) => Expanded(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/telegram_background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: BlocBuilder<FriendStatusBloc, FriendStatusState>(
            builder: (context, friendStatusState) {
              final friends = friendStatusState is FetchedFriendStatusState &&
                  friendStatusState.friends;

              return Stack(
                children: [
                  if (chatState is FetchingChatState &&
                      friendStatusState is! ErrorFriendStatusState)
                    _shimmedList(),
                  if (chatState is NoChatAvailableState &&
                      friendStatusState is FetchedFriendStatusState &&
                      !friendStatusState.friends)
                    _noFriendsWidget(context),
                  if (chatState is ChatWithMessagesState &&
                      friendStatusState is! ErrorFriendStatusState)
                    _messages(
                      context,
                      chat: chatState.chat,
                      messages: chatState.messages,
                      friends: friends,
                    ),
                  if (chatState is NoChatAvailableState && friends)
                    _noMessagesWidget(context),
                  if (chatState is ErrorChatState ||
                      friendStatusState is ErrorFriendStatusState)
                    _genericErrorWidget(context),
                ],
              );
            },
          ),
        ),
      );

  Widget _shimmedList() => ShimmedList(child: MessageWidget.shimmed());

  Widget _messages(
    BuildContext context, {
    required Chat chat,
    required List<Message> messages,
    bool friends = false,
  }) =>
      LayoutBuilder(
        builder: (context, constraints) => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          reverse: true,
          itemCount: messages.length + (friends ? 0 : 1),
          itemBuilder: (context, index) => index == 0 && !friends
              ? _noFriendsItem(context)
              : _chatItem(
                  context,
                  chat: chat,
                  message: messages[index - (friends ? 0 : 1)],
                  lastMessage: index == 0,
                  constraints: constraints,
                ),
        ),
      );

  Widget _noFriendsItem(BuildContext context) => Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.all(Radius.circular(16)),
              border: Border.all(color: Colors.grey[400]!)),
          child: Text(AppLocalizations.of(context)
                  ?.label_no_friends_answer(other.displayName) ??
              ''),
        ),
      );

  Widget _chatItem(
    BuildContext context, {
    required Chat chat,
    required Message message,
    bool lastMessage = false,
    required BoxConstraints constraints,
  }) {
    final sender = message.isSender(user.uid);

    return Align(
      alignment: sender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: constraints.maxWidth * 0.8,
        ),
        child: MessageWidget(
          message,
          sender: sender,
          onTap: sender
              ? (details) => _showContextMenu(
                    context,
                    chat: chat,
                    message: message,
                    lastMessage: lastMessage,
                    offset: details.globalPosition,
                  )
              : null,
        ),
      ),
    );
  }

  Widget _noFriendsWidget(BuildContext context) => Positioned(
        bottom: 16,
        left: 16,
        right: 16,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: Colors.grey[400]!),
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
            AppLocalizations.of(context)?.label_no_friends(other.displayName) ??
                '',
          ),
        ),
      );

  Widget _genericErrorWidget(BuildContext context) => Positioned(
        bottom: 16,
        left: 16,
        right: 16,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: Colors.grey[400]!),
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
            AppLocalizations.of(context)?.label_chat_error ?? '',
          ),
        ),
      );

  Widget _noMessagesWidget(BuildContext context) => Positioned(
        bottom: 16,
        left: 16,
        right: 16,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: Colors.grey[400]!),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)?.label_no_messages_available ?? '',
              ),
              MaterialButton(
                onPressed: () => context.read<ChatBloc>().sendMessage(
                      user: user.uid,
                      other: other.id!,
                      message: AppLocalizations.of(context)?.action_hello ?? '',
                    ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.handSparkles,
                      size: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        AppLocalizations.of(context)
                                ?.action_say_hi(other.displayName) ??
                            '',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _footer(BuildContext context, {bool disabled = false}) => Card(
        shape: Border(),
        margin: EdgeInsets.zero,
        child: StreamBuilder<bool>(
            stream: context.watch<ChatBloc>().emptyChat,
            builder: (context, snapshot) => Row(
                  children: [
                    _emojiButton(disabled: disabled),
                    _textField(context),
                    if (!snapshot.hasData || snapshot.data!)
                      _attachmentsButton(context, disabled: disabled),
                    if (!snapshot.hasData || snapshot.data!)
                      _audioButton(disabled: disabled),
                    if (snapshot.hasData && !snapshot.data!)
                      _sendMessageButton(context, disabled: disabled),
                  ],
                )),
      );

  Widget _emojiButton({bool disabled = false}) => IconButton(
        icon: Icon(Icons.emoji_emotions_outlined),
        onPressed: disabled ? null : () {},
      );

  Widget _textField(BuildContext context) => Expanded(
        child: TwoWayBindingBuilder<String>(
          binding: context.watch<ChatBloc>().messageBinding,
          builder: (
            context,
            controller,
            data,
            onChanged,
            error,
          ) =>
              TextField(
            minLines: 1,
            maxLines: 6,
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              errorText: error?.localizedString(context),
              hintText: AppLocalizations.of(context)?.label_message,
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.text,
          ),
        ),
      );

  Widget _attachmentsButton(BuildContext context, {bool disabled = false}) =>
      IconButton(
        icon: Icon(Icons.attachment),
        onPressed: disabled
            ? null
            : () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => bottomSheetPicker(
                    context,
                    title:
                        AppLocalizations.of(context)?.title_attach_file ?? '',
                  ),
                );
              },
      );

  Widget _audioButton({bool disabled = false}) => IconButton(
        onPressed: disabled ? null : () {},
        icon: Icon(Icons.mic),
      );

  Widget _sendMessageButton(BuildContext context, {bool disabled = false}) =>
      BlocBuilder<EditModeCubit, EditModeState>(
        builder: (context, state) {
          return IconButton(
            icon: Icon(
              state is EditModeDisabled ? Icons.send : Icons.check_circle,
              color: Colors.blue,
            ),
            onPressed: disabled
                ? null
                : state is EditModeEnabled
                    ? () {
                        context.read<ChatBloc>().updateMessage(
                              state.message.id!,
                              chat: state.chat,
                              lastMessage: state.lastMessage ?? false,
                            );

                        context.read<EditModeCubit>().disableEditMode();
                      }
                    : () => context
                        .read<ChatBloc>()
                        .sendMessage(user: user.uid, other: other.id!),
          );
        },
      );

  Widget _otherAvatar() => CircleAvatar(
        child: Text(other.avatar == null ? other.initials : ''),
        backgroundImage: other.avatar != null
            ? CachedNetworkImageProvider(other.avatar!)
            : null,
      );

  Widget _otherName(
    BuildContext context, {
    required models.User other,
  }) =>
      Text(
        other.displayName,
        style: Theme.of(context).textTheme.headline6?.copyWith(
              color: Colors.white,
            ),
      );

  Widget _otherLastAccess(
    BuildContext context, {
    required models.User other,
  }) =>
      Text(
        other.lastAccess != null
            ? timeago.format(
                other.lastAccess!,
                locale: AppLocalizations.of(context)?.localeName,
              )
            : AppLocalizations.of(context)?.label_last_access ?? '',
        style: Theme.of(context).textTheme.caption?.copyWith(
              color: Colors.white70,
            ),
      );

  void _shouldOpenAttachmentPage(
    BuildContext context, {
    required ImagePickerState state,
  }) {
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (state is PickedImageState) {
          context.router.push(
            AttachmentRoute(
                attachment: state.imageFile,
                other: other,
                onAttachmentResult: (upload) {
                  context.read<ImagePickerBloc>().reset();

                  if (upload) {
                    context.read<ChatBloc>().sendMessage(
                          user: user.uid,
                          other: other.id!,
                          attachment: state.imageFile,
                        );
                  }
                }),
          );
        }
      });
    }
  }

  void _showContextMenu(
    BuildContext context, {
    required Message message,
    required Chat chat,
    required Offset offset,
    bool lastMessage = false,
  }) async {
    final screenSize = MediaQuery.of(context).size;

    final action = await showMenu<_ContextMenuActions>(
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy,
          screenSize.width - offset.dx,
          screenSize.height - offset.dy,
        ),
        items: [
          if (message.attachmentUrl == null)
            PopupMenuItem(
              child:
                  Text(AppLocalizations.of(context)?.action_edit_message ?? ''),
              value: _ContextMenuActions.ACTION_UPDATE,
            ),
          PopupMenuItem(
            child:
                Text(AppLocalizations.of(context)?.action_delete_message ?? ''),
            value: _ContextMenuActions.ACTION_DELETE,
          ),
        ]);

    switch (action) {
      case _ContextMenuActions.ACTION_UPDATE:
        context.read<EditModeCubit>().enableEditMode(
              chat: chat.id!,
              message: message,
              lastMessage: lastMessage,
            );
        break;
      case _ContextMenuActions.ACTION_DELETE:
        _showDeleteMessageDialog(
          context,
          message: message,
          chat: chat,
          lastMessage: lastMessage,
        );
        break;
      default:
    }
  }

  void _showDeleteMessageDialog(
    BuildContext context, {
    required Message message,
    required Chat chat,
    bool lastMessage = false,
  }) {
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
                AppLocalizations.of(context)?.dialog_delete_message_title ??
                    ''),
            content: Text(
                AppLocalizations.of(context)?.dialog_delete_message_message ??
                    ''),
            actions: [
              TextButton(
                  onPressed: () {
                    context.read<ChatBloc>().deleteMessage(
                          message.id!,
                          chat: chat.id!,
                          lastMessage: lastMessage
                              ? AppLocalizations.of(context)
                                      ?.label_message_deleted ??
                                  ''
                              : null,
                        );

                    context.router.pop();
                  },
                  child: Text(AppLocalizations.of(context)?.action_yes ?? '')),
              TextButton(
                  onPressed: () {
                    context.router.pop();
                  },
                  child: Text(AppLocalizations.of(context)?.action_no ?? '')),
            ],
          ),
        );
      });
    }
  }

  void _shouldShowErrorSnackbar(
    BuildContext context, {
    required UserStatusState state,
  }) {
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (state is ErrorUserStatusState) {
          final scaffold = ScaffoldMessenger.of(context);

          scaffold.showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)?.label_other_error ?? ''),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: AppLocalizations.of(context)?.action_ok ?? '',
                onPressed: scaffold.hideCurrentSnackBar,
              ),
            ),
          );
        }
      });
    }
  }

  void _showDeleteChatDialog(
    BuildContext context, {
    required ChatAvailableState state,
  }) {
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
              title: Text(
                  AppLocalizations.of(context)?.dialog_delete_chat_title ?? ''),
              content: Text(
                  AppLocalizations.of(context)?.dialog_delete_chat_message ??
                      ''),
              actions: [
                TextButton(
                  onPressed: () {
                    context.read<ChatBloc>().deleteChat(
                          state.chat.id!,
                          streamSubscription: state.streamSubscription,
                        );
                    context.router.pop();
                  },
                  child: Text(AppLocalizations.of(context)?.action_yes ?? ''),
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)?.action_no ?? ''),
                  onPressed: () => context.router.pop(),
                ),
              ]),
        );
      });
    }
  }
}

enum _AppBarMenuActions {
  ACTION_DELETE,
}

enum _ContextMenuActions {
  ACTION_UPDATE,
  ACTION_DELETE,
}
