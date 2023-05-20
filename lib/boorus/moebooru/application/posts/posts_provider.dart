// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/domain/posts/moebooru_popular_repository.dart';
import 'package:boorusama/boorus/moebooru/infra/posts.dart';
import 'package:boorusama/boorus/moebooru/infra/posts/moebooru_post_repository_api.dart';
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';
import 'package:boorusama/core/application/blacklists.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/provider.dart';

final moebooruPostRepoProvider = Provider<PostRepository>(
  (ref) {
    final api = ref.watch(moebooruApiProvider);
    final blacklistedTagRepository =
        ref.watch(globalBlacklistedTagRepoProvider);
    final currentBooruConfigRepository =
        ref.watch(currentBooruConfigRepoProvider);
    final settingsRepository = ref.watch(settingsRepoProvider);

    return MoebooruPostRepositoryApi(
      api,
      blacklistedTagRepository,
      currentBooruConfigRepository,
      settingsRepository,
    );
  },
  dependencies: [
    moebooruApiProvider,
    globalBlacklistedTagRepoProvider,
    currentBooruConfigRepoProvider,
    settingsRepoProvider,
  ],
);

final moebooruPopularRepoProvider = Provider<MoebooruPopularRepository>(
  (ref) {
    final api = ref.watch(moebooruApiProvider);
    final blacklistedTagRepository =
        ref.watch(globalBlacklistedTagRepoProvider);
    final currentBooruConfigRepository =
        ref.watch(currentBooruConfigRepoProvider);

    return MoebooruPopularRepositoryApi(
      api,
      blacklistedTagRepository,
      currentBooruConfigRepository,
    );
  },
  dependencies: [
    moebooruApiProvider,
    globalBlacklistedTagRepoProvider,
    currentBooruConfigRepoProvider,
  ],
);
