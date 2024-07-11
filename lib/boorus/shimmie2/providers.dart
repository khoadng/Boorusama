// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/shimmie2/shimmie2_client.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
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
            .map((e) => Shimmie2Post(
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
                  metadata: PostMetadata(
                    page: page,
                    search: tags.join(' '),
                  ),
                ))
            .toList()
            .toResult();
      },
      getSettings: () async => ref.read(imageListingSettingsProvider),
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

  @override
  String getLink(String baseUrl) {
    return baseUrl.endsWith('/')
        ? '${baseUrl}post/view/$id'
        : '$baseUrl/post/view/$id';
  }
}
