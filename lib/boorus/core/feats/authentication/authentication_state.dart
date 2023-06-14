// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';

sealed class AuthenticationState extends Equatable {
  const AuthenticationState();
}

final class Authenticated extends AuthenticationState {
  const Authenticated({
    required this.booruConfig,
  });

  final BooruConfig booruConfig;

  @override
  List<Object?> get props => [booruConfig];
}

final class Unauthenticated extends AuthenticationState {
  @override
  List<Object?> get props => ['unauthenticated'];
}

extension AuthenticationStateX on AuthenticationState {
  bool get isAuthenticated => this is Authenticated;
}
