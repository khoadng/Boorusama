part of 'gelbooru_v1.dart';

final gelbooruV1PostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
  (ref, config) {
    final client = ref.watch(gelbooruV1ClientProvider(config.auth));

    return PostRepositoryBuilder(
      getComposer: () => ref.read(currentTagQueryComposerProvider),
      getSettings: () async => ref.read(imageListingSettingsProvider),
      fetch: (tags, page, {limit}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
        );

        return posts
            .map((e) => GelbooruV1Post(
                  id: e.id ?? 0,
                  thumbnailImageUrl: sanitizedUrl(e.previewUrl ?? ''),
                  sampleImageUrl: sanitizedUrl(e.sampleUrl ?? ''),
                  originalImageUrl: sanitizedUrl(e.fileUrl ?? ''),
                  tags: e.tags.splitTagString(),
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
                  uploaderId: null,
                  createdAt: null,
                  uploaderName: null,
                  metadata: PostMetadata(
                    page: page,
                    search: tags.join(' '),
                  ),
                ))
            .toList()
            .toResult();
      },
    );
  },
);

final gelbooruV1AutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
  final client = GelbooruClient.gelbooru();

  return AutocompleteRepositoryBuilder(
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
    persistentStaleDuration: const Duration(days: 1),
    autocomplete: (query) async {
      final dtos = await client.autocomplete(term: query);

      return dtos
          .map((e) => AutocompleteData(
                label: e.label ?? '<Unknown>',
                value: e.value ?? '<Unknown>',
              ))
          .toList();
    },
  );
});

final gelbooruV1ClientProvider =
    Provider.family<GelbooruV1Client, BooruConfigAuth>((ref, config) {
  final dio = ref.watch(dioProvider(config));

  return GelbooruV1Client(
    baseUrl: config.url,
    dio: dio,
  );
});

class GelbooruV1Post extends SimplePost {
  GelbooruV1Post({
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
        ? '${baseUrl}index.php?page=post&s=view&id=$id'
        : '$baseUrl/index.php?page=post&s=view&id=$id';
  }
}
