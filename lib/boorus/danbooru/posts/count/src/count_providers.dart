// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/posts/count/count.dart';

final danbooruPostCountRepoProvider =
    Provider.family<PostCountRepository, BooruConfigSearch>((ref, config) {
  return PostCountRepositoryBuilder(
    countTags: (tags) =>
        ref.read(danbooruClientProvider(config.auth)).countPosts(tags: tags),
    //TODO: this is a hack to get around the fact that count endpoint includes all ratings
    extraTags: config.auth.url == kDanbooruSafeUrl ? ['rating:g'] : [],
  );
});
