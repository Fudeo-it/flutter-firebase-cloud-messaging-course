import 'dart:collection';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:telegram_app/blocs/friends/friends_bloc.dart';
import 'package:telegram_app/blocs/users/users_bloc.dart';
import 'package:telegram_app/cubits/search_cubit.dart';
import 'package:telegram_app/mixin/search_components.dart';
import 'package:telegram_app/models/friend.dart';
import 'package:telegram_app/models/user.dart' as models;
import 'package:telegram_app/router/app_router.gr.dart';
import 'package:telegram_app/widgets/connectivity_widget.dart';
import 'package:telegram_app/widgets/my_error_widget.dart';
import 'package:telegram_app/widgets/shimmed_list.dart';
import 'package:telegram_app/widgets/side_header.dart';
import 'package:telegram_app/widgets/user_widget.dart';

class NewMessagePage extends ConnectivityWidget
    with AutoRouteWrapper, SearchComponentsMixin {
  final User user;

  NewMessagePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget wrappedRoute(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SearchCubit()),
          BlocProvider(
            create: (context) => FriendsBloc(
              friendRepository: context.read(),
            )..fetchFriends(user.uid),
          ),
          BlocProvider(
            create: (context) => UsersBloc(
              searchCubit: context.read(),
              userRepository: context.read(),
            ),
          ),
        ],
        child: this,
      );

  @override
  Widget connectedBuild(BuildContext context) => BlocBuilder<SearchCubit, bool>(
        builder: (context, isSearching) => Scaffold(
          appBar: _appBar(
            context,
            isSearching: isSearching,
          ),
          body: _body(context),
        ),
      );

  PreferredSizeWidget _appBar(BuildContext context, {isSearching = false}) =>
      AppBar(
        leading: BackButton(
          onPressed: () => isSearching
              ? context.read<SearchCubit>().toggle()
              : context.router.pop(),
        ),
        title: isSearching
            ? searchField(context)
            : Text(AppLocalizations.of(context)?.title_new_message ?? ''),
        actions: [
          if (!isSearching)
            IconButton(
              onPressed: () => context.read<SearchCubit>().toggle(),
              icon: Icon(Icons.search),
            ),
        ],
      );

  Widget _body(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        if (state is InitialUsersState) {
          return _friendsBody(context);
        } else if (state is NoUsersState) {
          return _noUsersWidget(context);
        } else if (state is ErrorUsersState) {
          return _usersErrorWidget(context);
        } else if (state is FetchedUsersState) {
          return _usersItems(context, users: state.users);
        }

        return _shimmedItems();
      },
    );
  }

  Widget _usersItems(BuildContext context,
          {required List<models.User> users}) =>
      ListView.builder(
        itemBuilder: (context, index) => UserWidget(
          users[index],
          onTap: () => context.router.popAndPush(
            ChatRoute(
              user: user,
              other: users[index],
            ),
          ),
        ),
        itemCount: users.length,
      );

  Widget _friendsBody(BuildContext context) =>
      BlocBuilder<FriendsBloc, FriendsState>(builder: (context, state) {
        if (state is FetchedFriendsState) {
          return _friendsItems(context, friends: state.friends);
        } else if (state is NoFriendsState) {
          return _noFriendsWidget(context);
        } else if (state is ErrorFriendsState) {
          return _friendsErrorWidget(context);
        }

        return _shimmedItems();
      });

  Widget _friendsItems(BuildContext context, {required List<Friend> friends}) {
    final groupedFriends = friends.fold<LinkedHashMap<String, List<Friend>>>(
      LinkedHashMap(),
      (map, friend) =>
          map..putIfAbsent(friend.user!.firstLetter, () => []).add(friend),
    );

    return DefaultStickyHeaderController(
      child: CustomScrollView(
        slivers: groupedFriends.values
            .map(
              (friends) => SliverStickyHeader(
                overlapsContent: true,
                header: SideHeader(friends.first.user!.firstLetter),
                sliver: SliverPadding(
                  padding: const EdgeInsets.only(left: 60),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => UserWidget(
                        friends[index].user,
                        onTap: () => context.router.popAndPush(
                          ChatRoute(
                            user: user,
                            other: friends[index].user!,
                          ),
                        ),
                      ),
                      childCount: friends.length,
                    ),
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _shimmedItems() => ShimmedList(
        child: UserWidget.shimmed(),
      );

  Widget _noFriendsWidget(BuildContext context) => MyErrorWidget(
        icon: Icons.people,
        subtitle: AppLocalizations.of(context)?.label_no_friends_msg ?? '',
      );

  Widget _friendsErrorWidget(BuildContext context) => MyErrorWidget(
        icon: Icons.people,
        title: AppLocalizations.of(context)?.label_error,
        subtitle: AppLocalizations.of(context)?.label_friend_list_error ?? '',
      );

  Widget _noUsersWidget(BuildContext context) => MyErrorWidget(
        icon: Icons.search,
        subtitle: AppLocalizations.of(context)?.label_no_users_found_msg ?? '',
      );

  Widget _usersErrorWidget(BuildContext context) => MyErrorWidget(
        icon: Icons.search,
        title: AppLocalizations.of(context)?.label_error,
        subtitle: AppLocalizations.of(context)?.label_user_list_error ?? '',
      );
}
