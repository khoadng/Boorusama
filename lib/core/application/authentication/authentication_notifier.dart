// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/authentication/authentication_state.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/provider.dart';

final authenticationProvider =
    NotifierProvider<AuthenticationNotifier, AuthenticationState>(
  () => throw UnimplementedError(),
  dependencies: [
    currentBooruConfigRepoProvider,
  ],
);

class AuthenticationNotifier extends Notifier<AuthenticationState> {
  @override
  AuthenticationState build() {
    return Unauthenticated();
  }

  Future<void> logIn() async {
    final repo = ref.read(currentBooruConfigRepoProvider);
    final booruConfig = await repo.get();

    if (booruConfig!.hasLoginDetails()) {
      state = Authenticated(booruConfig: booruConfig);
    } else {
      state = Unauthenticated();
    }
  }

  Future<void> logOut() async {
    state = Unauthenticated();
  }
}
