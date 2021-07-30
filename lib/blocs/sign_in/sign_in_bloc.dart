import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_essentials_kit/flutter_essentials_kit.dart';
import 'package:rxdart/rxdart.dart';
import 'package:telegram_app/cubits/auth/auth_cubit.dart';
import 'package:telegram_app/extensions/user_first_last_name.dart';
import 'package:telegram_app/models/user.dart' as models;
import 'package:telegram_app/repositories/authentication_repository.dart';
import 'package:telegram_app/repositories/user_repository.dart';

part 'sign_in_event.dart';

part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthenticationRepository authenticationRepository;
  final UserRepository userRepository;
  final AuthCubit authCubit;

  final emailBinding = TwoWayBinding<String>()
      .bindDataRule(RequiredRule())
      .bindDataRule(EmailRule());
  final passwordBinding = TwoWayBinding<String>().bindDataRule(RequiredRule());

  SignInBloc({
    required this.authenticationRepository,
    required this.userRepository,
    required this.authCubit,
  }) : super(InitialSignInState());

  Stream<bool> get areValidCredentials => Rx.combineLatest2(
      emailBinding.stream,
      passwordBinding.stream,
      (_, __) =>
          emailBinding.value != null &&
          emailBinding.value!.isNotEmpty &&
          passwordBinding.value != null &&
          passwordBinding.value!.isNotEmpty);

  @override
  Stream<SignInState> mapEventToState(
    SignInEvent event,
  ) async* {
    if (event is PerformSignInEvent || event is PerformSignInWithGoogleEvent) {
      yield SigningInState();

      UserCredential? userCredential;
      StreamSubscription? authSubscription;

      try {
        if (event is PerformSignInEvent) {
          userCredential = await authenticationRepository.signIn(
            email: event.email,
            password: event.password,
          );
        } else {
          authSubscription = authCubit.stream
              .where((state) => state is AuthenticatedState)
              .listen(
                  (state) => _updateUserProfile(state as AuthenticatedState));

          userCredential = await authenticationRepository.signInWithGoogle();
        }
      } catch (error) {
        yield ErrorSignInState();
      } finally {
        authSubscription?.cancel();
      }

      if (userCredential != null) {
        yield SuccessSignInState(userCredential);
      }
    }
  }

  @override
  Future<void> close() async {
    await emailBinding.close();
    await passwordBinding.close();

    return super.close();
  }

  void performSignIn({
    String? email,
    String? password,
  }) =>
      add(
        PerformSignInEvent(
          email: (email ?? emailBinding.value) ?? '',
          password: (password ?? passwordBinding.value) ?? '',
        ),
      );

  void performSignInWithGoogle() => add(PerformSignInWithGoogleEvent());

  void _updateUserProfile(AuthenticatedState state) async {
    final User user = state.user;
    final firstName = user.firstName;
    final lastName = user.lastName;
    final photoURL = user.photoURL;

    await userRepository.create(
      models.User(
        id: user.uid,
        firstName: firstName,
        lastName: lastName,
        avatar: photoURL,
        lastAccess: DateTime.now(),
      ),
    );
  }
}
