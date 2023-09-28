// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/pages/boorus/create_anon_config_page.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/clients/zerochan/types/types.dart';
import 'package:boorusama/clients/zerochan/zerochan_client.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/path.dart' as path;

final zerochanClientProvider = Provider<ZerochanClient>((ref) {
  final dio = newDio(ref.watch(dioArgsProvider));
  final logger = ref.watch(loggerProvider);

  return ZerochanClient(
    dio: dio,
    logger: (message) => logger.logE('ZerochanClient', message),
  );
});

final zerochanPostRepoProvider = Provider<PostRepository>(
  (ref) {
    final client = ref.watch(zerochanClientProvider);

    return PostRepositoryBuilder(
      getSettings: () async => ref.read(settingsProvider),
      getPosts: (tags, page, {limit}) async {
        final posts = await client.getPosts(
          tags: tags.split(' ').toList(),
          page: page,
        );

        return posts
            .map((e) => SimplePost(
                  id: e.id ?? 0,
                  thumbnailImageUrl: e.thumbnail ?? '',
                  sampleImageUrl: e.thumbnail ?? '',
                  originalImageUrl: e.fileUrl() ?? '',
                  tags: e.tags ?? [],
                  rating: Rating.general,
                  hasComment: false,
                  isTranslated: false,
                  hasParentOrChildren: false,
                  source: PostSource.from(e.source),
                  score: 0,
                  duration: 0,
                  fileSize: 0,
                  format: path.extension(e.thumbnail ?? ''),
                  hasSound: null,
                  height: e.height?.toDouble() ?? 0,
                  md5: '',
                  videoThumbnailUrl: '',
                  videoUrl: '',
                  width: e.width?.toDouble() ?? 0,
                  getLink: (baseUrl) => baseUrl.endsWith('/')
                      ? '$baseUrl${e.id}'
                      : '$baseUrl/${e.id}',
                ))
            .toList();
      },
    );
  },
);

final zerochanAutoCompleteRepoProvider =
    Provider<AutocompleteRepository>((ref) {
  final client = ref.watch(zerochanClientProvider);

  return AutocompleteRepositoryBuilder(
    persistentStorageKey: 'zerochan_autocomplete_cache_v1',
    persistentStaleDuration: const Duration(days: 1),
    autocomplete: (query) async {
      final tags = await client.getAutocomplete(query: query);

      return tags
          .map((e) => AutocompleteData(
                label: e.value?.toLowerCase() ?? '',
                value: e.value?.toLowerCase() ?? '',
                postCount: e.total,
                category: e.type?.toLowerCase() ?? '',
              ))
          .toList();
    },
  );
});

class ZerochanBuilder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        ArtistNotSupportedMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  const ZerochanBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
  });

  final AutocompleteRepository autocompleteRepo;
  final PostRepository postRepo;

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
  PostFetcher get postFetcher =>
      (page, tags) => postRepo.getPostsFromTags(tags, page);

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query.toLowerCase());
}
