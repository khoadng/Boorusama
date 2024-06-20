// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/core/configs/providers.dart';

class UserNotifier extends AutoDisposeFamilyAsyncNotifier<User, int> {
  @override
  Future<User> build(int arg) async {
    final config = ref.watchConfig;
    final user =
        await ref.watch(danbooruUserRepoProvider(config)).getUserById(arg);
    return user;
  }
}
