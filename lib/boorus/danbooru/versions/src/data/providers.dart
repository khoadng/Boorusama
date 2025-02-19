// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config.dart';
import '../../../danbooru_provider.dart';
import 'post_version_repository.dart';

final danbooruPostVersionsRepoProvider =
    Provider.family<DanbooruPostVersionRepository, BooruConfigAuth>(
        (ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return DanbooruPostVersionRepository(client: client);
});
