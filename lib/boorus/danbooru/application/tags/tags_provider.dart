// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/tags/tags.dart';
import 'package:boorusama/core/provider.dart';

final popularSearchProvider = Provider<PopularSearchRepository>(
  (ref) {
    final api = ref.watch(danbooruApiProvider);
    final currentBooruConfigRepository =
        ref.watch(currentBooruConfigRepoProvider);

    return PopularSearchRepositoryApi(
        currentBooruConfigRepository: currentBooruConfigRepository, api: api);
  },
  dependencies: [
    currentBooruConfigRepoProvider,
  ],
);
