import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:telegram_app/blocs/notification/notification_bloc.dart';
import 'package:telegram_app/cubits/auth/auth_cubit.dart';
import 'package:telegram_app/cubits/chats/chats_cubit.dart';
import 'package:telegram_app/cubits/scroll_cubit.dart';
import 'package:telegram_app/cubits/search_cubit.dart';
import 'package:telegram_app/extensions/user_display_name_initials.dart';
import 'package:telegram_app/mixin/search_components.dart';
import 'package:telegram_app/models/chat.dart';
import 'package:telegram_app/router/app_router.gr.dart';
import 'package:telegram_app/widgets/chat_widget.dart';
import 'package:telegram_app/widgets/my_error_widget.dart';
import 'package:telegram_app/widgets/shimmed_list.dart';

class HomePage extends StatefulWidget {
  final User user;

  HomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, SearchComponentsMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 250),
    );

    super.initState();
  }

  @override
  Widget build(_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SearchCubit(),
          ),
          BlocProvider(
            create: (_) => ScrollCubit(),
          ),
          BlocProvider(
            create: (context) => ChatsCubit(
              widget.user.uid,
              chatRepository: context.read(),
            ),
          ),
        ],
        child: LayoutBuilder(
          builder: (context, _) =>
              BlocListener<NotificationBloc, NotificationState>(
            listener: (context, state) {
              _shouldNavigateToChatPage(context, state: state);
            },
            child: BlocBuilder<SearchCubit, bool>(
              builder: (context, isSearching) => Scaffold(
                appBar: _appBar(
                  context,
                  isSearching: isSearching,
                ),
                drawer: _drawer(context),
                body: _body(
                  context,
                  isSearching: isSearching,
                ),
              ),
            ),
          ),
        ),
      );

  PreferredSizeWidget _appBar(
    BuildContext context, {
    bool isSearching = false,
  }) =>
      AppBar(
        leading: LayoutBuilder(
          builder: (context, _) => IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.menu_arrow,
              progress: _animationController,
            ),
            onPressed: () {
              if (isSearching) {
                context.read<SearchCubit>().toggle();
                _animationController.reverse();
              } else {
                Scaffold.of(context).openDrawer();
              }
            },
          ),
        ),
        title: isSearching
            ? searchField(context)
            : Text(AppLocalizations.of(context)?.app_name ?? ''),
        actions: [
          if (!isSearching)
            IconButton(
              onPressed: () {
                context.read<SearchCubit>().toggle();

                _animationController.forward();
              },
              icon: Icon(
                Icons.search,
              ),
            ),
        ],
      );

  Widget _drawer(BuildContext context) => Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _accountHeader(context),
                  _newMessageButton(context),
                ],
              ),
            ),
            Divider(height: 0),
            _logoutButton(context),
          ],
        ),
      );

  Widget _newMessageButton(BuildContext context) => ListTile(
        leading: Icon(
          Icons.edit,
        ),
        title: Text(AppLocalizations.of(context)?.action_new_message ?? ''),
        onTap: () => context.router.push(
          NewMessageRoute(user: widget.user),
        ),
      );

  Widget _accountHeader(BuildContext context) => UserAccountsDrawerHeader(
        accountName: widget.user.displayName != null
            ? Text(widget.user.displayName!)
            : null,
        accountEmail:
            widget.user.email != null ? Text(widget.user.email!) : null,
        currentAccountPicture: CircleAvatar(
          backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
              ? Colors.blue
              : Colors.white,
          backgroundImage: widget.user.photoURL != null
              ? CachedNetworkImageProvider(widget.user.photoURL!)
              : null,
          child: widget.user.photoURL == null
              ? Text(
                  widget.user.displayName != null
                      ? widget.user.displayNameInitials
                      : '',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                )
              : Container(),
        ),
      );

  Widget _logoutButton(BuildContext context) => ListTile(
        leading: Icon(Icons.logout),
        title: Text(AppLocalizations.of(context)?.action_logout ?? ''),
        onTap: () => _showLogoutDialog(context),
      );

  Widget _body(
    BuildContext context, {
    bool isSearching = false,
  }) =>
      Stack(
        children: [
          _chatsBody(context),
          _fab(isSearching: isSearching),
        ],
      );

  Widget _chatsBody(BuildContext context) =>
      BlocBuilder<ChatsCubit, ChatsState>(
        builder: (context, state) {
          if (state is FetchedChatsState) {
            return _chatItems(context, chats: state.chats);
          } else if (state is NoChatsState) {
            return _noChatsWidget(context);
          } else if (state is ErrorChatsState) {
            return _chatsErrorWidget(context);
          }

          return _loadingItems();
        },
      );

  Widget _loadingItems() => ShimmedList(
        child: ChatWidget.shimmed(),
      );

  Widget _chatItems(BuildContext context, {required List<Chat> chats}) =>
      StreamBuilder<String?>(
          stream: context.watch<SearchCubit>().searchBinding.stream,
          builder: (context, snapshot) {
            final filteredChats = chats
                .where(
                  (chat) =>
                      !snapshot.hasData ||
                      chat.displayName
                          .toLowerCase()
                          .contains(snapshot.data!.toLowerCase()) ||
                      chat.lastMessage
                          .toLowerCase()
                          .contains(snapshot.data!.toLowerCase()),
                )
                .toList(growable: false);

            if (filteredChats.isEmpty) {
              return _chatsNotFoundWidget(context);
            }

            return NotificationListener<ScrollNotification>(
              child: ListView.builder(
                itemBuilder: (context, index) => ChatWidget(
                  filteredChats[index],
                  onTap: () => context.router.push(
                    ChatRoute(
                      user: widget.user,
                      other: filteredChats[index].user!,
                    ),
                  ),
                ),
                itemCount: filteredChats.length,
              ),
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  context.read<ScrollCubit>().start();
                } else if (notification is ScrollEndNotification) {
                  context.read<ScrollCubit>().stop();
                }

                return false;
              },
            );
          });

  Widget _fab({isSearching = false}) => BlocBuilder<ScrollCubit, bool>(
        builder: (context, isScrolling) => AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          right: 24,
          bottom: isSearching || isScrolling ? -100 : 24,
          child: FloatingActionButton(
            child: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: () =>
                context.router.push(NewMessageRoute(user: widget.user)),
          ),
        ),
      );

  void _shouldNavigateToChatPage(
    BuildContext context, {
    required NotificationState state,
  }) {
    if (state is AvailableNotificationState) {
      context.router.popUntilRoot();
      context.router.push(
        ChatRoute(user: widget.user, other: state.chat.user!),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title:
                Text(AppLocalizations.of(context)?.dialog_logout_title ?? ''),
            content:
                Text(AppLocalizations.of(context)?.dialog_logout_message ?? ''),
            actions: [
              TextButton(
                onPressed: () {
                  context.read<AuthCubit>().signOut();
                  context.router.pop();
                },
                child: Text(AppLocalizations.of(context)?.action_yes ?? ''),
              ),
              TextButton(
                onPressed: () => context.router.pop(),
                child: Text(AppLocalizations.of(context)?.action_no ?? ''),
              ),
            ],
          ),
        );
      });
    }
  }

  Widget _chatsNotFoundWidget(BuildContext context) => MyErrorWidget(
        icon: Icons.chat,
        subtitle: AppLocalizations.of(context)?.label_no_chats_found_msg ?? '',
      );

  Widget _noChatsWidget(BuildContext context) => MyErrorWidget(
        icon: Icons.chat,
        subtitle: AppLocalizations.of(context)?.label_no_chats_msg ?? '',
      );

  Widget _chatsErrorWidget(BuildContext context) => MyErrorWidget(
        icon: Icons.chat,
        title: AppLocalizations.of(context)?.label_error,
        subtitle: AppLocalizations.of(context)?.label_chat_list_error ?? '',
      );
}
