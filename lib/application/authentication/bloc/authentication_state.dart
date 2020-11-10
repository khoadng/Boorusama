part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationUnknown extends AuthenticationState {}

class Authenticating extends AuthenticationState {}

class Unauthenticated extends AuthenticationState {
  final Account account;

  Unauthenticated({
    @required this.account,
  });
}

class Authenticated extends AuthenticationState {
  final Account account;

  Authenticated({
    @required this.account,
  });
}
