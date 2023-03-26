part of 'authentication_cubit.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
}

class Authenticated extends AuthenticationState {
  const Authenticated({
    required this.userBooru,
  });

  final BooruConfig userBooru;

  @override
  List<Object?> get props => [userBooru];
}

class Unauthenticated extends AuthenticationState {
  @override
  List<Object?> get props => ['unauthenticated'];
}
