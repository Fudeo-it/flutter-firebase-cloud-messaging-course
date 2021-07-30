import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telegram_app/blocs/notification/notification_bloc.dart';
import 'package:telegram_app/cubits/auth/auth_cubit.dart';
import 'package:telegram_app/cubits/dark_mode_cubit.dart';
import 'package:telegram_app/misc/mappers/chat_firebase_mapper.dart';
import 'package:telegram_app/misc/mappers/firebase_mapper.dart';
import 'package:telegram_app/misc/mappers/friend_firebase_mapper.dart';
import 'package:telegram_app/misc/mappers/message_firebase_mapper.dart';
import 'package:telegram_app/misc/mappers/user_firebase_mapper.dart';
import 'package:telegram_app/models/chat.dart';
import 'package:telegram_app/models/friend.dart';
import 'package:telegram_app/models/message.dart';
import 'package:telegram_app/models/user.dart' as models;
import 'package:telegram_app/providers/shared_preferences_provider.dart';
import 'package:telegram_app/repositories/authentication_repository.dart';
import 'package:telegram_app/repositories/chat_repository.dart';
import 'package:telegram_app/repositories/friend_repository.dart';
import 'package:telegram_app/repositories/message_repository.dart';
import 'package:telegram_app/repositories/profile_repository.dart';
import 'package:telegram_app/repositories/user_repository.dart';
import 'package:telegram_app/services/image_picker_service.dart';

class DependencyInjector extends StatelessWidget {
  final Widget child;

  const DependencyInjector({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _providers(
        child: _mappers(
          child: _repositories(
            child: _blocs(
              child: child,
            ),
          ),
        ),
      );

  Widget _providers({required Widget child}) => MultiProvider(
        providers: [
          Provider<SharedPreferencesProvider>(
            create: (_) => SharedPreferencesProvider(
              sharedPreferences: SharedPreferences.getInstance(),
            ),
          ),
          Provider<FirebaseAuth>(
            create: (_) => FirebaseAuth.instance,
          ),
          Provider<GoogleSignIn>(
            create: (_) => GoogleSignIn(scopes: [
              'https://www.googleapis.com/auth/userinfo.email',
              'https://www.googleapis.com/auth/userinfo.profile',
            ]),
          ),
          Provider<FirebaseFirestore>(
            create: (_) => FirebaseFirestore.instance,
          ),
          Provider<FirebaseDatabase>(
            create: (_) => FirebaseDatabase(app: Firebase.app()),
          ),
          Provider<FirebaseStorage>(
            create: (_) => FirebaseStorage.instance,
          ),
          Provider<ImagePickerService>(
            create: (_) => ImagePickerService(),
          ),
          Provider<FirebaseMessaging>(
            create: (_) => FirebaseMessaging.instance,
          ),
        ],
        child: child,
      );

  Widget _mappers({required Widget child}) => MultiProvider(
        providers: [
          Provider<FirebaseMapper<models.User>>(
            create: (_) => UserFirebaseMapper(),
          ),
          Provider<FirebaseMapper<Chat>>(
            create: (_) => ChatFirebaseMapper(),
          ),
          Provider<FirebaseMapper<Friend>>(
            create: (_) => FriendFirebaseMapper(),
          ),
          Provider<FirebaseMapper<Message>>(
            create: (_) => MessageFirebaseMapper(),
          ),
        ],
        child: child,
      );

  Widget _repositories({required Widget child}) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => AuthenticationRepository(
              firebaseAuth: context.read(),
              googleSignIn: context.read(),
            ),
          ),
          RepositoryProvider(
            create: (context) => UserRepository(
              firebaseFirestore: context.read(),
              userMapper: context.read(),
            ),
          ),
          RepositoryProvider(
            create: (context) => ChatRepository(
              firebaseFirestore: context.read(),
              chatMapper: context.read(),
              userMapper: context.read(),
            ),
          ),
          RepositoryProvider(
            create: (context) => FriendRepository(
              firebaseFirestore: context.read(),
              friendMapper: context.read(),
              userMapper: context.read(),
            ),
          ),
          RepositoryProvider(
            create: (context) => MessageRepository(
              firebaseDatabase: context.read(),
              firebaseStorage: context.read(),
              messageMapper: context.read(),
            ),
          ),
          RepositoryProvider(
            create: (context) => ProfileRepository(
              firebaseStorage: context.read(),
            ),
          ),
        ],
        child: child,
      );

  Widget _blocs({required Widget child}) => MultiBlocProvider(
        providers: [
          BlocProvider<DarkModeCubit>(
            create: (context) => DarkModeCubit(
              preferencesProvider: context.read(),
            )..init(),
          ),
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              firebaseAuth: context.read(),
            ),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => NotificationBloc(
              firebaseMessaging: context.read(),
              chatRepository: context.read(),
              contextProvider: () => context,
            )..checkNotificationEvent(),
          ),
        ],
        child: child,
      );
}
