part of 'sign_up_bloc.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();
}

class PerformSignUpEvent extends SignUpEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final File? avatar;

  PerformSignUpEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.avatar,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        password,
        avatar,
      ];
}
