part of 'authentication_cubit.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
}

class AuthenticationInitial extends AuthenticationState {
  @override
  List<Object?> get props => ['initial'];
}

class AuthenticationInProgress extends AuthenticationState {
  @override
  List<Object?> get props => ['inProgress'];
}

class Authenticated extends AuthenticationState {
  const Authenticated({
    required this.account,
  });

  final Account account;

  @override
  List<Object?> get props => [account];
}

class Unauthenticated extends AuthenticationState {
  @override
  List<Object?> get props => ['unauthenticated'];
}

class AuthenticationError extends AuthenticationState {
  const AuthenticationError({
    required this.exception,
    required this.stackTrace,
  });

  final Exception exception;
  final StackTrace stackTrace;

  @override
  List<Object?> get props => [exception, stackTrace];
}
