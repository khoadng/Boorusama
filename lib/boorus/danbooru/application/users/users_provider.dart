// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/users.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/provider.dart';

final danbooruUserRepoProvider = Provider<UserRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final booruConfig = ref.watch(currentBooruConfigProvider);

  return UserRepositoryApi(
    api,
    booruConfig,
    [], //FIXME: shouldn't be empty
  );
});

final danbooruCurrentUserProvider =
    NotifierProvider<CurrentUserNotifier, UserSelf?>(
  CurrentUserNotifier.new,
  dependencies: [
    danbooruUserRepoProvider,
    currentBooruConfigProvider,
    booruUserIdentityProviderProvider
  ],
);
