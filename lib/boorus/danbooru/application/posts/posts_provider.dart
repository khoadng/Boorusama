// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/notes.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/count/post_count_repository_api.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/provider.dart';
import 'post_details_artist_notifier.dart';
import 'post_details_character_notifier.dart';
import 'post_details_children_notifier.dart';
import 'post_details_pools_notifier.dart';
import 'post_details_tags_notifier.dart';

//#region Post Count
final postCountRepoProvider = Provider<PostCountRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final currentBooruConfig = ref.watch(currentBooruConfigProvider);
  final currentBooru = ref.watch(currentBooruProvider);

  return PostCountRepositoryApi(
    api: api,
    booruConfig: currentBooruConfig,
    //TODO: this is a hack to get around the fact that count endpoint includes all ratings
    extraTags:
        currentBooru.booruType == BooruType.safebooru ? ['rating:general'] : [],
  );
});

final postCountStateProvider =
    NotifierProvider<PostCountNotifier, PostCountState>(
  PostCountNotifier.new,
  dependencies: [
    postCountRepoProvider,
  ],
);

final postCountProvider = Provider<PostCountState>((ref) {
  return ref.watch(postCountStateProvider);
}, dependencies: [
  postCountStateProvider,
]);
//#endregion

final danbooruPostDetailsArtistProvider = NotifierProvider.autoDispose
    .family<PostDetailsArtistNotifier, List<Recommend<DanbooruPost>>, int>(
  PostDetailsArtistNotifier.new,
  dependencies: [
    danbooruArtistCharacterPostRepoProvider,
  ],
);

final danbooruPostDetailsCharacterProvider = NotifierProvider.autoDispose
    .family<PostDetailsCharacterNotifier, List<Recommend<DanbooruPost>>, int>(
  PostDetailsCharacterNotifier.new,
  dependencies: [
    danbooruArtistCharacterPostRepoProvider,
  ],
);

final danbooruPostDetailsChildrenProvider = NotifierProvider.autoDispose
    .family<PostDetailsChildrenNotifier, List<DanbooruPost>, int>(
  PostDetailsChildrenNotifier.new,
  dependencies: [
    danbooruPostRepoProvider,
  ],
);

final danbooruPostDetailsNoteProvider = NotifierProvider.autoDispose
    .family<PostDetailsNoteNotifier, PostDetailsNoteState, Post>(
  PostDetailsNoteNotifier.new,
  dependencies: [
    danbooruNoteProvider,
  ],
);

final danbooruPostDetailsPoolsProvider = NotifierProvider.autoDispose
    .family<PostDetailsPoolsNotifier, List<Pool>, int>(
  PostDetailsPoolsNotifier.new,
  dependencies: [
    poolRepoProvider,
  ],
);

final danbooruPostDetailsTagsProvider = NotifierProvider.autoDispose
    .family<PostDetailsTagsNotifier, List<PostDetailTag>, int>(
  PostDetailsTagsNotifier.new,
);

final postShareProvider =
    NotifierProvider.family<PostShareNotifier, PostShareState, Post>(
  PostShareNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
    booruFactoryProvider,
  ],
);
