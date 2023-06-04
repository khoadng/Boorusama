// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/users.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/features/tags/tags.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/provider.dart';

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
