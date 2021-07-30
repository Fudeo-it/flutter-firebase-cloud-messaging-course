// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'dart:io' as _i11;

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:firebase_auth/firebase_auth.dart' as _i9;
import 'package:flutter/material.dart' as _i2;
import 'package:telegram_app/models/user.dart' as _i10;
import 'package:telegram_app/pages/attachment_page.dart' as _i8;
import 'package:telegram_app/pages/chat_page.dart' as _i7;
import 'package:telegram_app/pages/main_page.dart' as _i3;
import 'package:telegram_app/pages/new_message_page.dart' as _i6;
import 'package:telegram_app/pages/sign_in_page.dart' as _i4;
import 'package:telegram_app/pages/sign_up_page.dart' as _i5;

class AppRouter extends _i1.RootStackRouter {
  AppRouter([_i2.GlobalKey<_i2.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    MainRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i3.MainPage();
        }),
    SignInRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i4.SignInPage();
        }),
    SignUpRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i5.SignUpPage();
        }),
    NewMessageRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<NewMessageRouteArgs>();
          return _i6.NewMessagePage(key: args.key, user: args.user);
        }),
    ChatRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<ChatRouteArgs>();
          return _i7.ChatPage(
              key: args.key, user: args.user, other: args.other);
        }),
    AttachmentRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<AttachmentRouteArgs>();
          return _i8.AttachmentPage(args.attachment,
              key: args.key,
              other: args.other,
              onAttachmentResult: args.onAttachmentResult);
        })
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(MainRoute.name, path: '/'),
        _i1.RouteConfig(SignInRoute.name, path: '/sign-in-page'),
        _i1.RouteConfig(SignUpRoute.name, path: '/sign-up-page'),
        _i1.RouteConfig(NewMessageRoute.name, path: '/new-message-page'),
        _i1.RouteConfig(ChatRoute.name, path: '/chat-page'),
        _i1.RouteConfig(AttachmentRoute.name, path: '/attachment-page')
      ];
}

class MainRoute extends _i1.PageRouteInfo {
  const MainRoute() : super(name, path: '/');

  static const String name = 'MainRoute';
}

class SignInRoute extends _i1.PageRouteInfo {
  const SignInRoute() : super(name, path: '/sign-in-page');

  static const String name = 'SignInRoute';
}

class SignUpRoute extends _i1.PageRouteInfo {
  const SignUpRoute() : super(name, path: '/sign-up-page');

  static const String name = 'SignUpRoute';
}

class NewMessageRoute extends _i1.PageRouteInfo<NewMessageRouteArgs> {
  NewMessageRoute({_i2.Key? key, required _i9.User user})
      : super(name,
            path: '/new-message-page',
            args: NewMessageRouteArgs(key: key, user: user));

  static const String name = 'NewMessageRoute';
}

class NewMessageRouteArgs {
  const NewMessageRouteArgs({this.key, required this.user});

  final _i2.Key? key;

  final _i9.User user;
}

class ChatRoute extends _i1.PageRouteInfo<ChatRouteArgs> {
  ChatRoute({_i2.Key? key, required _i9.User user, required _i10.User other})
      : super(name,
            path: '/chat-page',
            args: ChatRouteArgs(key: key, user: user, other: other));

  static const String name = 'ChatRoute';
}

class ChatRouteArgs {
  const ChatRouteArgs({this.key, required this.user, required this.other});

  final _i2.Key? key;

  final _i9.User user;

  final _i10.User other;
}

class AttachmentRoute extends _i1.PageRouteInfo<AttachmentRouteArgs> {
  AttachmentRoute(
      {required _i11.File attachment,
      _i2.Key? key,
      required _i10.User other,
      required void Function(bool) onAttachmentResult})
      : super(name,
            path: '/attachment-page',
            args: AttachmentRouteArgs(
                attachment: attachment,
                key: key,
                other: other,
                onAttachmentResult: onAttachmentResult));

  static const String name = 'AttachmentRoute';
}

class AttachmentRouteArgs {
  const AttachmentRouteArgs(
      {required this.attachment,
      this.key,
      required this.other,
      required this.onAttachmentResult});

  final _i11.File attachment;

  final _i2.Key? key;

  final _i10.User other;

  final void Function(bool) onAttachmentResult;
}
