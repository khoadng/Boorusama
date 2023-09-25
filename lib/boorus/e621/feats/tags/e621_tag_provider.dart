// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/tags/e621_tag_repository.dart';

final e621TagRepoProvider = Provider<E621TagRepository>((ref) {
  return E621TagRepositoryApi(
    ref.watch(e621ClientProvider),
    ref.watch(currentBooruConfigProvider),
  );
});
