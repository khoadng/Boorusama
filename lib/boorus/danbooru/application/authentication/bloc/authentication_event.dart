part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationRequested extends AuthenticationEvent {}

class UserLoggedIn extends AuthenticationEvent {
  final String username;
  final String password;

  UserLoggedIn({
    @required this.username,
    @required this.password,
  });
}

class UserLoggedOut extends AuthenticationEvent {
  final int accountId;

  UserLoggedOut({
    @required this.accountId,
  });
}
