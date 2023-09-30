// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

class CurrentUserNotifier extends FamilyNotifier<UserSelf?, BooruConfig> {
  @override
  UserSelf? build(BooruConfig arg) {
    fetch();
    return null;
  }

  Future<void> fetch() async {
    final id = await ref
        .watch(booruUserIdentityProviderProvider(arg))
        .getAccountIdFromConfig(arg);
    if (id == null) return;

    state = await ref.read(danbooruUserRepoProvider(arg)).getUserSelfById(id);
  }
}
