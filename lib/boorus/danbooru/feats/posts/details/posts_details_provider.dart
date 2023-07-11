// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';

final danbooruPostDetailsArtistProvider = NotifierProvider.autoDispose
    .family<PostDetailsArtistNotifier, List<Recommend<DanbooruPost>>, int>(
  PostDetailsArtistNotifier.new,
  dependencies: [
    danbooruArtistCharacterPostRepoProvider,
    danbooruBlacklistedTagsProvider,
  ],
);

final danbooruPostDetailsCharacterProvider = NotifierProvider.autoDispose
    .family<PostDetailsCharacterNotifier, List<Recommend<DanbooruPost>>, int>(
  PostDetailsCharacterNotifier.new,
  dependencies: [
    danbooruArtistCharacterPostRepoProvider,
    danbooruBlacklistedTagsProvider,
  ],
);

final danbooruPostDetailsChildrenProvider = NotifierProvider.autoDispose
    .family<PostDetailsChildrenNotifier, List<DanbooruPost>, int>(
  PostDetailsChildrenNotifier.new,
  dependencies: [
    danbooruPostRepoProvider,
  ],
);

final danbooruPostDetailsPoolsProvider = NotifierProvider.autoDispose
    .family<PostDetailsPoolsNotifier, List<Pool>, int>(
  PostDetailsPoolsNotifier.new,
  dependencies: [
    danbooruPoolRepoProvider,
  ],
);

final danbooruPostDetailsTagsProvider = NotifierProvider.autoDispose
    .family<PostDetailsTagsNotifier, List<PostDetailTag>, int>(
  PostDetailsTagsNotifier.new,
);
