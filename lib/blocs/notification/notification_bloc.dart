import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:telegram_app/models/chat.dart';
import 'package:telegram_app/repositories/chat_repository.dart';

part 'notification_event.dart';

part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseMessaging firebaseMessaging;
  final ChatRepository chatRepository;
  final BuildContext Function() contextProvider;

  late StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;
  late StreamSubscription<RemoteMessage>? _onMessageSubscription;

  final AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'telegram_app_channel',
    'Chat Notifications',
    'This channel is used for chat notifications.',
    groupId: 'telegram_app_group',
  );
  final _flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
  final _initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  final _initializationSettingsiOS = IOSInitializationSettings();

  NotificationBloc({
    required this.firebaseMessaging,
    required this.chatRepository,
    required this.contextProvider,
  }) : super(NoNotificationState()) {
    final initializationSettings = InitializationSettings(
      android: _initializationSettingsAndroid,
      iOS: _initializationSettingsiOS,
    );

    _flutterLocalNotificationPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) async {
      if (payload != null) {
        Map<String, dynamic> data = json.decode(payload);
        add(EmitNotificationEvent(data));
      }
    });

    firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _onMessageOpenedAppSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] == 'chat') {
        add(EmitNotificationEvent(message.data));
      }
    });

    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;

      if (notification != null) {
        final defaultAndroidNotificationDetails = AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );

        final defaultiOSNotificationDetails =
            IOSNotificationDetails(threadIdentifier: _channel.groupId);

        final defaultNotificationDetails = NotificationDetails(
          android: defaultAndroidNotificationDetails,
          iOS: defaultiOSNotificationDetails,
        );

        _flutterLocalNotificationPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          defaultNotificationDetails,
          payload: json.encode(message.data),
        );

        final activeNotifications = await _flutterLocalNotificationPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.getActiveNotifications();

        if (activeNotifications != null && activeNotifications.length > 1) {
          await _flutterLocalNotificationPlugin.cancelAll();

          final lines =
              activeNotifications.fold<List<String>>([], (list, notification) {
            if (notification.title != null) {
              list.add(notification.title!);
            }

            return list;
          }).toList(growable: false);

          final context = contextProvider();

          final inboxStyleInfo = InboxStyleInformation(
            lines,
            contentTitle: AppLocalizations.of(context)
                    ?.label_new_messages('${activeNotifications.length - 1}') ??
                '',
            summaryText: AppLocalizations.of(context)
                    ?.label_new_messages('${activeNotifications.length - 1}') ??
                '',
          );

          final groupedAndroidNotificationDetails = AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            _channel.description,
            groupKey: _channel.groupId,
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
            setAsGroupSummary: true,
            styleInformation: inboxStyleInfo,
          );

          final groupedNotificationDetails =
              NotificationDetails(android: groupedAndroidNotificationDetails);

          _flutterLocalNotificationPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            groupedNotificationDetails,
            payload: json.encode(message.data),
          );
        }
      }
    });
  }

  @override
  Stream<NotificationState> mapEventToState(
    NotificationEvent event,
  ) async* {
    if (event is CheckNotificationEvent) {
      yield* _mapCheckNotificationEventToState(event);
    } else if (event is EmitNotificationEvent) {
      yield* _mapEmitNotificationEventToState(event);
    }
  }

  @override
  Future<void> close() async {
    await _onMessageSubscription?.cancel();
    await _onMessageOpenedAppSubscription?.cancel();

    return super.close();
  }

  Stream<NotificationState> _mapCheckNotificationEventToState(
      CheckNotificationEvent event) async* {
    final message = await firebaseMessaging.getInitialMessage();

    if (message != null && message.data['type'] == 'chat') {
      yield* _openChatFromNotification(message.data);
    }
  }

  Stream<NotificationState> _mapEmitNotificationEventToState(
      EmitNotificationEvent event) async* {
    if (event.payload['type'] == 'chat') {
      yield* _openChatFromNotification(event.payload);
    }
  }

  Stream<NotificationState> _openChatFromNotification(
      Map<String, dynamic> data) async* {
    final String? me = data['other'];
    final String? other = data['sender'];

    if (me != null && other != null) {
      final chats = await chatRepository.find(me, other: other);

      if (chats.length == 1) {
        yield AvailableNotificationState(chats.first);
      }
    }
  }

  void checkNotificationEvent() => add(CheckNotificationEvent());
}
