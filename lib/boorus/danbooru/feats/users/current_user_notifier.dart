// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';

class CurrentUserNotifier extends Notifier<UserSelf?> {
  @override
  UserSelf? build() {
    final booruConfig = ref.watch(currentBooruConfigProvider);

    //FIXME: should handle this in a better way
    if (!booruConfig.booruType.isDanbooruBased) return null;

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
