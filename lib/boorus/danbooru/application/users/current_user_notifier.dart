// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/users/users_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/core/provider.dart';

class CurrentUserNotifier extends Notifier<UserSelf?> {
  //TODO: watch auth state and fetch user when auth state changes
  @override
  UserSelf? build() {
    fetch();
    return null;
  }

  Future<void> fetch() async {
    final config = await ref.read(currentBooruConfigRepoProvider).get();
    final id = await ref
        .watch(booruUserIdentityProviderProvider)
        .getAccountIdFromConfig(config);
    if (id == null) return;

    state = await ref.read(danbooruUserRepoProvider).getUserSelfById(id);
  }
}
