// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/posts/posts.dart';
import '../models/danbooru_post.dart';
import '../models/danbooru_post_repository.dart';
import 'posts_provider.dart';

class PostDetailsCharacterNotifier
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

  Future<void> load(DanbooruPost post) =>
      fetchPosts(post.characterTags, RecommendType.character);
}
