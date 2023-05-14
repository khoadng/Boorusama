// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/utils.dart';

mixin PostDetailsTagsX<T extends Post>
    on AutoDisposeFamilyNotifier<List<Recommend<T>>, int> {
  Future<List<T>> Function(String tag, int page) get fetcher;
  final Map<String, List<T>> tagCache = {};

  Future<void> fetchPosts(
    List<String> tags,
    RecommendType type, {
    int? limit,
  }) async {
    for (final tag in tags) {
      if (state.any((e) => e.tag == tag)) continue;
      var posts =
          tagCache.containsKey(tag) ? tagCache[tag]! : await fetcher(tag, 1);

      // if limit is not null, then we only want to get the first [limit] posts
      if (limit != null) {
        posts = posts.take(limit).toList();
      }

      tagCache[tag] = posts;

      state = [
        ...state,
        Recommend(
          type: type,
          title: tag.removeUnderscoreWithSpace(),
          tag: tag,
          posts: posts.where((e) => !e.isFlash).toList(),
        ),
      ];
    }
  }
}

final booruPostDetailsArtistProvider = NotifierProvider.autoDispose
    .family<BooruPostDetailsArtistNotifier, List<Recommend<Post>>, int>(
  BooruPostDetailsArtistNotifier.new,
  dependencies: [
    postRepoProvider,
  ],
);

class BooruPostDetailsArtistNotifier
    extends AutoDisposeFamilyNotifier<List<Recommend<Post>>, int>
    with PostRepositoryMixin, PostDetailsTagsX<Post> {
  @override
  PostRepository get postRepository => ref.read(postRepoProvider);

  @override
  Future<List<Post>> Function(String tag, int page) get fetcher =>
      (tags, page) => postRepository.getPostsFromTagsOrEmpty(tags, page);

  @override
  List<Recommend<Post>> build(int arg) => [];

  Future<void> load(List<Tag> tags) => fetchPosts(
        tags
            .where((e) => e.category == TagCategory.artist)
            .map((e) => e.rawName)
            .toList(),
        RecommendType.artist,
      );
}

extension PostDetailsX on Post {
  void loadArtistPostsFrom(WidgetRef ref, List<TagGroupItem> tagGroup) {
    final t = tagGroup
        .firstWhereOrNull((e) => e.groupName.toLowerCase() == 'artist')
        ?.tags;

    if (t != null) {
      ref.read(booruPostDetailsArtistProvider(id).notifier).load(t);
    }
  }
}
