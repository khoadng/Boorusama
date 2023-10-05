// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/shimmie2/shimmie2_client.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/path.dart';

final shimmie2ClientProvider = Provider.family<Shimmie2Client, BooruConfig>(
  (ref, config) {
    final dio = newDio(ref.watch(dioArgsProvider(config)));

    return Shimmie2Client(
      dio: dio,
      baseUrl: config.url,
    );
  },
);

final shimmie2PostRepoProvider = Provider.family<PostRepository, BooruConfig>(
  (ref, config) {
    final client = ref.watch(shimmie2ClientProvider(config));

    return PostRepositoryBuilder(
      fetch: (tags, page, {limit}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
          limit: limit,
        );

        return posts
            .map((e) => SimplePost(
                  id: e.id ?? 0,
                  thumbnailImageUrl: e.previewUrl ?? '',
                  sampleImageUrl: e.fileUrl ?? '',
                  originalImageUrl: e.fileUrl ?? '',
                  tags: e.tags ?? [],
                  rating: mapStringToRating(e.rating),
                  hasComment: false,
                  isTranslated: false,
                  hasParentOrChildren: false,
                  source: PostSource.from(e.source),
                  score: e.score ?? 0,
                  duration: 0,
                  fileSize: 0,
                  format: extension(e.fileUrl ?? ''),
                  hasSound: null,
                  height: e.height?.toDouble() ?? 0,
                  md5: e.md5 ?? '',
                  videoThumbnailUrl: e.previewUrl ?? '',
                  videoUrl: e.fileUrl ?? '',
                  width: e.width?.toDouble() ?? 0,
                  getLink: (baseUrl) => baseUrl.endsWith('/')
                      ? '${baseUrl}post/view/${e.id}'
                      : '$baseUrl/post/view/${e.id}',
                  createdAt: e.date,
                ))
            .toList();
      },
      getSettings: () async => ref.read(settingsProvider),
    );
  },
);

final shimmie2AutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfig>(
  (ref, config) {
    final client = ref.watch(shimmie2ClientProvider(config));

    return AutocompleteRepositoryBuilder(
      persistentStorageKey:
          '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      autocomplete: (query) async {
        final tags = await client.getAutocomplete(query: query);

        return tags
            .map((e) => AutocompleteData(
                  label: e.value?.toLowerCase().replaceAll('_', ' ') ?? '???',
                  value: e.value?.toLowerCase() ?? '???',
                  postCount: e.count,
                ))
            .toList();
      },
    );
  },
);
