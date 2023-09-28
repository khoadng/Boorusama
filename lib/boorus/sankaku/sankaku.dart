// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocomplete.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/sankaku/create_sankaku_config_page.dart';
import 'package:boorusama/clients/sankaku/sankaku_client.dart';
import 'package:boorusama/foundation/networking/networking.dart';

final sankakuClientProvider = Provider<SankakuClient>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = newDio(ref.watch(dioArgsProvider));

  return SankakuClient(
    dio: dio,
    baseUrl: booruConfig.url,
    username: booruConfig.login,
    password: booruConfig.apiKey,
  );
});

final sankakuPostRepoProvider = Provider<PostRepository>(
  (ref) {
    final client = ref.watch(sankakuClientProvider);

    return PostRepositoryBuilder(
      getSettings: () async => ref.read(settingsProvider),
      getPosts: (tags, page, {limit}) async {
        final posts = await client.getPosts(
          tags: tags.split(' '),
          page: page,
          limit: limit,
        );

        return posts.map((e) {
          final hasParent = e.parentId != null;
          final hasChilren = e.hasChildren ?? false;
          final hasParentOrChildren = hasParent || hasChilren;

          return SimplePost(
            id: e.id ?? 0,
            thumbnailImageUrl: e.previewUrl ?? '',
            sampleImageUrl: e.sampleUrl ?? '',
            originalImageUrl: e.fileUrl ?? '',
            tags: e.tags?.map((e) => e.name).whereNotNull().toList() ?? [],
            rating: mapStringToRating(e.rating),
            hasComment: e.hasComments ?? false,
            isTranslated: false,
            hasParentOrChildren: hasParentOrChildren,
            source: PostSource.from(e.source),
            score: e.totalScore ?? 0,
            duration: e.videoDuration ?? 0,
            fileSize: e.fileSize ?? 0,
            format: extractFileExtension(e.fileType) ?? '',
            hasSound: null,
            height: e.height?.toDouble() ?? 0,
            md5: e.md5 ?? '',
            videoThumbnailUrl: e.previewUrl ?? '',
            videoUrl: e.fileUrl ?? '',
            width: e.width?.toDouble() ?? 0,
            getLink: (_) => '${client.originalUrl}/post/show/${e.md5}',
          );
        }).toList();
      },
    );
  },
);

String? extractFileExtension(String? mimeType) {
  if (mimeType == null) return null;
  final parts = mimeType.split('/');
  return parts.length >= 2 ? '.${parts[1]}' : null;
}

class SankakuBuilder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        ArtistNotSupportedMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  SankakuBuilder({
    required this.postRepository,
    required this.client,
  });

  final PostRepository postRepository;
  final SankakuClient client;

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => client.getAutocomplete(query: query).then((value) => value
          .map((e) => AutocompleteData(
                label: e.name?.replaceAll('_', ' ') ?? '???',
                value: e.name ?? '???',
                postCount: e.count,
                category: e.type?.toString(),
              ))
          .toList());

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateSankakuConfigPage(
            config: BooruConfig.defaultConfig(booruType: booruType, url: url),
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher =>
      (tags, page, {limit}) => postRepository.getPostsFromTags(page, tags);
}
