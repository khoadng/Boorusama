// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/core/boorus/boorus.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
}

class Authenticated extends AuthenticationState {
  const Authenticated({
    required this.booruConfig,
  });

  final BooruConfig booruConfig;

  @override
  List<Object?> get props => [booruConfig];
}

class Unauthenticated extends AuthenticationState {
  @override
  List<Object?> get props => ['unauthenticated'];
}
