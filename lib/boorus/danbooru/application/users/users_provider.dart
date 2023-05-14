// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/users/current_user_notifier.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/core/provider.dart';

final danbooruUserRepoProvider = Provider<UserRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final booruUserConfigRepo = ref.watch(currentBooruConfigRepoProvider);

  return UserRepositoryApi(
    api,
    booruUserConfigRepo,
    [], //FIXME: shouldn't be empty
  );
});

final danbooruCurrentUserProvider =
    NotifierProvider<CurrentUserNotifier, UserSelf?>(
  CurrentUserNotifier.new,
  dependencies: [
    danbooruUserRepoProvider,
    currentBooruConfigRepoProvider,
    booruUserIdentityProviderProvider
  ],
);
