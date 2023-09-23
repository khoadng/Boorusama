// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/string.dart';

mixin PostDetailsTagsX<T extends Post>
    on AutoDisposeFamilyNotifier<List<Recommend<T>>, int> {
  Future<List<T>> Function(String tag, int page) get fetcher;
  final _cache = Cache<List<T>>(
    staleDuration: const Duration(minutes: 10),
    maxCapacity: 100,
  );

  GlobalBlacklistedTagRepository get blacklistedTagRepository =>
      ref.read(globalBlacklistedTagRepoProvider);

  List<String> get blacklistedTags;

  Future<void> fetchPosts(
    List<String> tags,
    RecommendType type, {
    int? limit,
  }) async {
    final blacklistedTags = await blacklistedTagRepository.getBlacklist();

    for (final tag in tags) {
      if (state.any((e) => e.tag == tag)) continue;
      List<T> posts;

      if (_cache.exist(tag)) {
        posts = _cache.get(tag)!;
      } else {
        posts = await fetcher(tag, 1);
        _cache.set(tag, posts);
      }

      // if limit is not null, then we only want to get the first [limit] posts
      if (limit != null) {
        posts = posts.take(limit).toList();
      }

      state = [
        ...state,
        Recommend(
          type: type,
          title: tag.replaceUnderscoreWithSpace(),
          tag: tag,
          posts: filterTags(
            posts.where((e) => !e.isFlash).toList(),
            {
              ...blacklistedTags.map((e) => e.name),
              ...this.blacklistedTags,
            },
          ),
        ),
      ];
    }
  }
}

final booruPostDetailsArtistProvider = NotifierProvider.autoDispose
    .family<BooruPostDetailsArtistNotifier, List<Recommend<Post>>, int>(
  BooruPostDetailsArtistNotifier.new,
  dependencies: [
    postArtistCharacterRepoProvider,
  ],
);

class BooruPostDetailsArtistNotifier
    extends AutoDisposeFamilyNotifier<List<Recommend<Post>>, int>
    with PostRepositoryMixin, PostDetailsTagsX<Post> {
  @override
  PostRepository get postRepository => ref.read(
      postArtistCharacterRepoProvider(ref.read(currentBooruConfigProvider)));

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

  @override
  List<String> get blacklistedTags => [];
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
