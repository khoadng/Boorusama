// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/blacklists/global_blacklisted_tags_provider.dart';
import 'package:boorusama/boorus/core/feat/boorus/providers.dart';
import 'package:boorusama/boorus/core/feat/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/moebooru/features/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/features/tags/moebooru_post_repository_api.dart';
import 'package:boorusama/boorus/moebooru/features/tags/tags.dart';
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';

final moebooruPostRepoProvider = Provider<PostRepository>(
  (ref) {
    final api = ref.watch(moebooruApiProvider);
    final blacklistedTagRepository =
        ref.watch(globalBlacklistedTagRepoProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);

    final settingsRepository = ref.watch(settingsRepoProvider);

    return MoebooruPostRepositoryApi(
      api,
      blacklistedTagRepository,
      booruConfig,
      settingsRepository,
    );
  },
  dependencies: [
    moebooruApiProvider,
    globalBlacklistedTagRepoProvider,
    currentBooruConfigProvider,
    settingsRepoProvider,
  ],
);

final moebooruPopularRepoProvider = Provider<MoebooruPopularRepository>(
  (ref) {
    final api = ref.watch(moebooruApiProvider);
    final blacklistedTagRepository =
        ref.watch(globalBlacklistedTagRepoProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return MoebooruPopularRepositoryApi(
      api,
      blacklistedTagRepository,
      booruConfig,
    );
  },
  dependencies: [
    moebooruApiProvider,
    globalBlacklistedTagRepoProvider,
    currentBooruConfigProvider,
  ],
);
