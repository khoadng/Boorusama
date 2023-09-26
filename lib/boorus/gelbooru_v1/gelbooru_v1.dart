// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/pages/boorus/create_anon_config_page.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_v1_client.dart';
import 'package:boorusama/functional.dart';

final gelbooruV1PostRepoProvider = Provider<PostRepository>(
  (ref) {
    final settingsRepository = ref.watch(settingsRepoProvider);
    final client = ref.watch(gelbooruV1ClientProvider);

    return PostRepositoryBuilder(
      settingsRepository: settingsRepository,
      getPosts: (tags, page, {limit}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
        );

        return posts
            .map((e) => SimplePost(
                  id: e.id ?? 0,
                  thumbnailImageUrl: e.previewUrl ?? '',
                  sampleImageUrl: e.sampleUrl ?? '',
                  originalImageUrl: e.fileUrl ?? '',
                  tags: e.tags?.split(' ').toList() ?? [],
                  rating: mapStringToRating(e.rating),
                  hasComment: false,
                  isTranslated: false,
                  hasParentOrChildren: false,
                  source: PostSource.none(),
                  score: e.score ?? 0,
                  duration: 0,
                  fileSize: 0,
                  format: extension(e.fileUrl ?? ''),
                  hasSound: null,
                  height: 0,
                  md5: e.md5 ?? '',
                  videoThumbnailUrl: e.previewUrl ?? '',
                  videoUrl: e.fileUrl ?? '',
                  width: 0,
                  getLink: (baseUrl) =>
                      '$baseUrl/index.php?page=post&s=view&id=${e.id}',
                ))
            .toList();
      },
    );
  },
);

final gelbooruV1ClientProvider = Provider<GelbooruV1Client>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return GelbooruV1Client(
    baseUrl: booruConfig.url,
    dio: dio,
  );
});

class GelbooruV1Builder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        ArtistNotSupportedMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  const GelbooruV1Builder({
    required this.postRepo,
  });

  final PostRepository postRepo;

  @override
  AutocompleteFetcher get autocompleteFetcher => (tags) => Future.value([]);

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateAnonConfigPage(
            url: url,
            booruType: booruType,
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher => (page, tags) => TaskEither.Do(($) async {
        final posts = await $(postRepo.getPostsFromTags(tags, page));

        return posts;
      });
}
