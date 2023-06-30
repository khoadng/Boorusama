// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';

final danbooruBlacklistedTagRepoProvider = Provider<BlacklistedTagsRepository>(
  (ref) {
    return BlacklistedTagsRepositoryImpl(
      ref.watch(danbooruUserRepoProvider),
      ref.watch(danbooruApiProvider),
    );
  },
  dependencies: [
    danbooruUserRepoProvider,
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
