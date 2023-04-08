// Project imports:
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/tags.dart';

mixin DanbooruPostDataTransformMixin<T, E> on PostCubit<T, E> {
  BlacklistedTagsRepository get blacklistedTagsRepository;
  FavoritePostRepository get favoritePostRepository;
  CurrentBooruConfigRepository get currentBooruConfigRepository;
  PostVoteRepository get postVoteRepository;
  PoolRepository get poolRepository;
  PostPreviewPreloader? get previewPreloader;

  Future<List<DanbooruPostData>> transform(List<DanbooruPost> posts) =>
      Future.value(posts)
          .then(createPostDataWith(
            favoritePostRepository,
            postVoteRepository,
            poolRepository,
            currentBooruConfigRepository,
          ))
          .then(filterWith(
            blacklistedTagsRepository,
            currentBooruConfigRepository,
          ))
          .then(filterFlashFiles())
          .then(preloadPreviewImagesWith(previewPreloader));
}
