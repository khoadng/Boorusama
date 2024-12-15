// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../e621.dart';
import 'e621_tag_repository.dart';

final e621TagRepoProvider =
    Provider.family<E621TagRepository, BooruConfigAuth>((ref, config) {
  return E621TagRepositoryApi(
    ref.watch(e621ClientProvider(config)),
    config,
  );
});
