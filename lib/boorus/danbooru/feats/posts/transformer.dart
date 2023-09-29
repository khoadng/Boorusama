// Dart imports:
import 'dart:async';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/core/feats/booru_user_identity_provider.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/preloaders/preloaders.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'danbooru_post.dart';

mixin DanbooruPostTransformMixin<T, E> {
  BlacklistedTagsRepository get blacklistedTagsRepository;
  BooruConfig get booruConfig;
  PoolRepository get poolRepository;
  PostPreviewPreloader? get previewPreloader;
  BooruUserIdentityProvider get booruUserIdentityProvider;
  void Function(List<int> ids) get checkFavorites;
  void Function(List<int> ids) get checkVotes;

  Future<List<DanbooruPost>> transform(List<DanbooruPost> posts) async {
    final id =
        await booruUserIdentityProvider.getAccountIdFromConfig(booruConfig);
    if (id != null) {
      final ids = posts.map((e) => e.id).toList();
      checkFavorites(ids);
      checkVotes(ids);
    }

    return Future.value(posts)
        .then(filterFlashFiles())
        .then(preloadPreviewImagesWith(previewPreloader));
  }
}

Future<List<DanbooruPost>> Function(List<DanbooruPost> posts)
    preloadPreviewImagesWith(
  PostPreviewPreloader? preloader,
) =>
        (posts) async {
          if (preloader != null) {
            for (final post in posts) {
              unawaited(preloader.preload(post));
            }
          }

          return posts;
        };

Future<List<DanbooruPost>> Function(List<DanbooruPost> posts)
    filterFlashFiles() => filterUnsupportedFormat({'swf'});

Future<List<DanbooruPost>> Function(List<DanbooruPost> posts)
    filterUnsupportedFormat(
  Set<String> fileExtensions,
) =>
        (posts) async => posts
            .where((e) => !fileExtensions.contains(e.format))
            .where((e) => !e.metaTags.contains('flash'))
            .toList();
