// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/features/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/features/users/users.dart';
import 'package:boorusama/core/boorus/providers.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/tags/tags.dart';

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
