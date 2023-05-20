// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/domain/posts/moebooru_popular_repository.dart';
import 'package:boorusama/boorus/moebooru/infra/posts.dart';
import 'package:boorusama/boorus/moebooru/infra/posts/moebooru_post_repository_api.dart';
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';
import 'package:boorusama/core/application/blacklists.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/provider.dart';

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
