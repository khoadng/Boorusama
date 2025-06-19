// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/configs/config.dart';
import '../../core/foundation/path.dart';
import '../../core/http/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/sources/source.dart';
import '../../core/search/queries/providers.dart';
import '../../core/settings/providers.dart';

final shimmie2ClientProvider = Provider.family<Shimmie2Client, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(dioProvider(config));

    return Shimmie2Client(
      dio: dio,
      baseUrl: config.url,
    );
  },
);

final shimmie2PostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
  (ref, config) {
    final client = ref.watch(shimmie2ClientProvider(config.auth));

    return PostRepositoryBuilder(
      getComposer: () => ref.read(tagQueryComposerProvider(config)),
      fetchSingle: (id, {options}) {
        return Future.value(null);
      },
      fetch: (tags, page, {limit, options}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
          limit: limit,
        );

        return posts
            .map(
              (e) => _postDtoToPost(
                e,
                PostMetadata(
                  page: page,
                  search: tags.join(' '),
                  limit: limit,
                ),
              ),
            )
            .toList()
            .toResult();
      },
      getSettings: () async => ref.read(imageListingSettingsProvider),
    );
  },
);

Shimmie2Post _postDtoToPost(
  PostDto e,
  PostMetadata? metadata,
) {
  return Shimmie2Post(
    id: e.id ?? 0,
    thumbnailImageUrl: e.previewUrl ?? '',
    sampleImageUrl: e.fileUrl ?? '',
    originalImageUrl: e.fileUrl ?? '',
    tags: e.tags?.toSet() ?? {},
    rating: mapStringToRating(e.rating),
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.from(e.source),
    score: e.score ?? 0,
    duration: 0,
    fileSize: 0,
    format: extension(e.fileName ?? ''),
    hasSound: null,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5 ?? '',
    videoThumbnailUrl: e.previewUrl ?? '',
    videoUrl: e.fileUrl ?? '',
    width: e.width?.toDouble() ?? 0,
    createdAt: e.date,
    uploaderId: null,
    uploaderName: e.author,
    metadata: metadata,
  );
}

final shimmie2AutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(shimmie2ClientProvider(config));

    return AutocompleteRepositoryBuilder(
      persistentStorageKey:
          '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      autocomplete: (query) async {
        final tags = await client.getAutocomplete(query: query.text);

        return tags
            .map(
              (e) => AutocompleteData(
                label: e.value?.toLowerCase().replaceAll('_', ' ') ?? '???',
                value: e.value?.toLowerCase() ?? '???',
                postCount: e.count,
              ),
            )
            .toList();
      },
    );
  },
);

class Shimmie2Post extends SimplePost {
  Shimmie2Post({
    required super.id,
    required super.thumbnailImageUrl,
    required super.sampleImageUrl,
    required super.originalImageUrl,
    required super.tags,
    required super.rating,
    required super.hasComment,
    required super.isTranslated,
    required super.hasParentOrChildren,
    required super.source,
    required super.score,
    required super.duration,
    required super.fileSize,
    required super.format,
    required super.hasSound,
    required super.height,
    required super.md5,
    required super.videoThumbnailUrl,
    required super.videoUrl,
    required super.width,
    required super.uploaderId,
    required super.createdAt,
    required super.uploaderName,
    required super.metadata,
  });
}
