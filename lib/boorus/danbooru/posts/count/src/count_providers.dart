// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config.dart';
import '../../../../../core/configs/constants.dart';
import '../../../../../core/posts/count/count.dart';
import '../../../client_provider.dart';

final danbooruPostCountRepoProvider =
    Provider.family<PostCountRepository, BooruConfigSearch>((ref, config) {
      return PostCountRepositoryBuilder(
        countTags: (tags) => ref
            .read(danbooruClientProvider(config.auth))
            .countPosts(tags: tags),
        //TODO: this is a hack to get around the fact that count endpoint includes all ratings
        extraTags: config.auth.url == kDanbooruSafeUrl ? ['rating:g'] : [],
      );
    });
