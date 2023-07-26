// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';

class PostDetailsArtistNotifier
    extends AutoDisposeFamilyNotifier<List<Recommend<DanbooruPost>>, int>
    with DanbooruPostRepositoryMixin, PostDetailsTagsX<DanbooruPost> {
  @override
  DanbooruPostRepository get postRepository =>
      ref.read(danbooruArtistCharacterPostRepoProvider);

  @override
  Future<List<DanbooruPost>> Function(String tag, int page) get fetcher =>
      (tags, page) => getPostsOrEmpty(tags, page);

  @override
  List<Recommend<DanbooruPost>> build(int arg) => [];

  Future<void> load(DanbooruPost post) => fetchPosts(
        post.artistTags,
        RecommendType.artist,
        limit: 30,
      );

  @override
  List<String> get blacklistedTags =>
      ref.read(danbooruBlacklistedTagsProvider) ?? [];
}
