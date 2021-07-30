part of 'users_bloc.dart';

abstract class UsersState extends Equatable {
  const UsersState();
  
  @override
  List<Object?> get props => [];
}

class InitialUsersState extends UsersState {
}

class SearchingUsersState extends UsersState {

}

class FetchedUsersState extends UsersState {
  final List<User> users;

  FetchedUsersState(this.users);

  @override
  List<Object?> get props => [users];
}

class NoUsersState extends UsersState {}

class ErrorUsersState extends UsersState {}
