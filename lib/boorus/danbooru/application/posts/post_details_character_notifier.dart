// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/posts/details.dart';
import 'package:boorusama/core/domain/posts.dart';

final danbooruPostDetailsCharacterProvider = NotifierProvider.autoDispose
    .family<PostDetailsCharacterNotifier, List<Recommend<DanbooruPost>>, int>(
  PostDetailsCharacterNotifier.new,
  dependencies: [
    danbooruArtistCharacterPostRepoProvider,
  ],
);

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
