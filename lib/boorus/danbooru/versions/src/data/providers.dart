// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/config.dart';
import 'post_version_repository.dart';

final danbooruPostVersionsRepoProvider =
    Provider.family<DanbooruPostVersionRepository, BooruConfigAuth>(
        (ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return DanbooruPostVersionRepository(client: client);
});
