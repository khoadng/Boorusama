// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feat/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/feat/users/users.dart';

final danbooruBlacklistedTagRepoProvider = Provider<BlacklistedTagsRepository>(
  (ref) {
    final userRepository = ref.watch(danbooruUserRepoProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);

    final api = ref.watch(danbooruApiProvider);

    return BlacklistedTagsRepositoryImpl(userRepository, booruConfig, api);
  },
  dependencies: [
    danbooruUserRepoProvider,
    currentBooruConfigProvider,
    danbooruApiProvider,
  ],
);

final danbooruBlacklistedTagsProvider =
    NotifierProvider.autoDispose<BlacklistedTagsNotifier, List<String>?>(
  BlacklistedTagsNotifier.new,
  dependencies: [
    booruUserIdentityProviderProvider,
    danbooruBlacklistedTagRepoProvider,
    currentBooruConfigProvider,
  ],
);
