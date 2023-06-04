// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/boorus/providers.dart';
import 'package:boorusama/boorus/danbooru/features/users/users.dart';

class UserNotifier extends FamilyAsyncNotifier<User, int> {
  UserRepository get repo => ref.watch(danbooruUserRepoProvider);

  @override
  Future<User> build(int arg) async {
    ref.watch(currentBooruConfigProvider);
    final user = await repo.getUserById(arg);
    return user;
  }
}
