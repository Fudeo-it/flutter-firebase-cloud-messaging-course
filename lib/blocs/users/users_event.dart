part of 'users_bloc.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class ResetSearchEvent extends UsersEvent {}

class SearchUsersEvent extends UsersEvent {
  final String query;

  SearchUsersEvent(this.query);

  @override
  List<Object?> get props => [query];
}
