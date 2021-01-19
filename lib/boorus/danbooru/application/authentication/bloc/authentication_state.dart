part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationUnknown extends AuthenticationState {}

class Authenticating extends AuthenticationState {}

class AuthenticationError extends AuthenticationState {
  final String error;
  final String message;

  AuthenticationError({
    @required this.error,
    @required this.message,
  });

  @override
  List<Object> get props => [error, message];
}

class Unauthenticated extends AuthenticationState {
  final int accountId;

  Unauthenticated({
    @required this.accountId,
  });
  @override
  List<Object> get props => [accountId];
}

class Authenticated extends AuthenticationState {
  final Account account;

  Authenticated({
    @required this.account,
  });
  @override
  List<Object> get props => [account];
}
