// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/authentication/authentication_state.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/boorus.dart';

final authenticationProvider =
    NotifierProvider<AuthenticationNotifier, AuthenticationState>(
  AuthenticationNotifier.new,
);

class AuthenticationNotifier extends Notifier<AuthenticationState> {
  @override
  AuthenticationState build() {
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return logIn(booruConfig);
  }

  AuthenticationState logIn(BooruConfig booruConfig) {
    if (booruConfig.hasLoginDetails()) {
      return Authenticated(booruConfig: booruConfig);
    } else {
      return Unauthenticated();
    }
  }

  void logOut() {
    state = Unauthenticated();
  }
}
