// Package imports:
import 'package:booru_clients/gelbooru.dart';

// Project imports:
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/providers.dart';
import '../gelbooru_v2_repository.dart';
import 'parser.dart';
import 'types.dart';

typedef GelbooruV2PostFetcher =
    Future<GelbooruV2Posts> Function(
      List<String> tags,
      int page, {
      int? limit,
      PostFetchOptions? options,
    });

typedef GelbooruV2PostSingleFetcher =
    Future<PostV2Dto?> Function(
      int id, {
      PostFetchOptions? options,
    });

class GelbooruV2PostRepository extends PostRepositoryBuilder<GelbooruV2Post> {
  GelbooruV2PostRepository({
    required super.getSettings,
    required super.tagComposer,
    required GelbooruV2PostFetcher fetcher,
    required GelbooruV2PostSingleFetcher fetchSingle,
    required GelbooruV2ImageUrlResolver imageUrlResolver,
  }) : super(
         fetch: (tags, page, {limit, options}) => _getPostResults(
           tags,
           page,
           getPosts: fetcher,
           imageUrlResolver: imageUrlResolver,
           limit: limit,
           options: options,
         ),
         fetchSingle: (id, {options}) async {
           final numericId = id as NumericPostId?;

           if (numericId == null) return Future.value();

           final post = await fetchSingle(numericId.value);

           return post != null
               ? gelbooruV2PostDtoToGelbooruPost(
                   post,
                   null,
                   imageUrlResolver,
                 )
               : null;
         },
         fetchFromController: (controller, page, {limit, options}) {
           final tags = controller.tags.map((e) => e.originalTag).toList();

           final newTags = tagComposer.compose(tags);

           return _getPostResults(
             newTags,
             page,
             limit: limit,
             getPosts: fetcher,
             imageUrlResolver: imageUrlResolver,
             options: options,
           );
         },
       );

  static Future<PostResult<GelbooruV2Post>> _getPostResults(
    List<String> tags,
    int page, {
    required GelbooruV2ImageUrlResolver imageUrlResolver,
    required GelbooruV2PostFetcher getPosts,
    int? limit,
    PostFetchOptions? options,
  }) async {
    final posts = await getPosts(tags, page, limit: limit);

    return posts.posts
        .map(
          (e) => gelbooruV2PostDtoToGelbooruPost(
            e,
            PostMetadata(
              page: page,
              search: tags.join(' '),
              limit: limit,
            ),
            imageUrlResolver,
          ),
        )
        .toList()
        .toResult(total: posts.count);
  }
}
