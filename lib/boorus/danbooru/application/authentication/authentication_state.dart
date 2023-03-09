part of 'authentication_cubit.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
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
