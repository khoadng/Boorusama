// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/boorus/szurubooru/favorites/favorites.dart';
import 'package:boorusama/clients/szurubooru/szurubooru_client.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/path.dart';
import 'szurubooru_post.dart';

final szurubooruClientProvider = Provider.family<SzurubooruClient, BooruConfig>(
  (ref, config) {
    final dio = newDio(ref.watch(dioArgsProvider(config)));

    return SzurubooruClient(
      dio: dio,
      baseUrl: config.url,
      username: config.login,
      token: config.apiKey,
    );
  },
);

final szurubooruPostRepoProvider = Provider.family<PostRepository, BooruConfig>(
  (ref, config) {
    final client = ref.watch(szurubooruClientProvider(config));

    return PostRepositoryBuilder(
      fetch: (tags, page, {limit}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
          limit: limit,
        );

        final data = posts
            .map((e) => SzurubooruPost(
                  id: e.id ?? 0,
                  thumbnailImageUrl: e.thumbnailUrl ?? '',
                  sampleImageUrl: e.contentUrl ?? '',
                  originalImageUrl: e.contentUrl ?? '',
                  tags: e.tags
                          ?.map((e) => e.names?.firstOrNull)
                          .whereNotNull()
                          .toList() ??
                      [],
                  rating: switch (e.safety?.toLowerCase()) {
                    'safe' => Rating.general,
                    'questionable' => Rating.questionable,
                    'sketchy' => Rating.questionable,
                    'unsafe' => Rating.explicit,
                    _ => Rating.general,
                  },
                  hasComment: (e.commentCount ?? 0) > 0,
                  isTranslated: (e.noteCount ?? 0) > 0,
                  hasParentOrChildren: (e.relationCount ?? 0) > 0,
                  source: PostSource.from(e.source),
                  score: e.score ?? 0,
                  duration: 0,
                  fileSize: e.fileSize ?? 0,
                  format: extension(e.contentUrl ?? ''),
                  hasSound: e.flags?.contains('sound'),
                  height: e.canvasHeight?.toDouble() ?? 0,
                  md5: e.checksumMD5 ?? '',
                  videoThumbnailUrl: e.thumbnailUrl ?? '',
                  videoUrl: e.contentUrl ?? '',
                  width: e.canvasWidth?.toDouble() ?? 0,
                  createdAt: e.creationTime != null
                      ? DateTime.tryParse(e.creationTime!)
                      : null,
                  uploaderName: e.user?.name,
                  ownFavorite: e.ownFavorite ?? false,
                  favoriteCount: e.favoriteCount ?? 0,
                  commentCount: e.commentCount ?? 0,
                ))
            .toList();

        ref.read(szurubooruFavoritesProvider(config).notifier).preload(data);

        return data;
      },
      getSettings: () async => ref.read(settingsProvider),
    );
  },
);

final szurubooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfig>(
  (ref, config) {
    final client = ref.watch(szurubooruClientProvider(config));

    return AutocompleteRepositoryBuilder(
      persistentStorageKey:
          '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      autocomplete: (query) async {
        // if not logged in, don't autocomplete
        if (!config.hasLoginDetails()) return [];

        final tags = await client.autocomplete(query: query);

        return tags
            .map((e) => AutocompleteData(
                  label: e.names?.firstOrNull
                          ?.toLowerCase()
                          .replaceAll('_', ' ') ??
                      '???',
                  value: e.names?.firstOrNull?.toLowerCase() ?? '???',
                  postCount: e.usages,
                ))
            .toList();
      },
    );
  },
);
