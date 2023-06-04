// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/features/users/users.dart';

class CurrentUserNotifier extends Notifier<UserSelf?> {
  @override
  UserSelf? build() {
    final booruConfig = ref.watch(currentBooruConfigProvider);

    fetch(booruConfig);
    return null;
  }

  Future<void> fetch(BooruConfig booruConfig) async {
    final id = await ref
        .watch(booruUserIdentityProviderProvider)
        .getAccountIdFromConfig(booruConfig);
    if (id == null) return;

    state = await ref.read(danbooruUserRepoProvider).getUserSelfById(id);
  }
}
