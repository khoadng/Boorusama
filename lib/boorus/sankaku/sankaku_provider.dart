part of 'sankaku.dart';

final sankakuClientProvider = Provider.family<SankakuClient, BooruConfig>(
  (ref, config) {
    final dio = newDio(ref.watch(dioArgsProvider(config)));
    final booruFactory = ref.watch(booruFactoryProvider);
    final booru = booruFactory.create(type: config.booruType);

    return SankakuClient(
      dio: dio,
      baseUrl: config.url,
      username: config.login,
      password: config.apiKey,
      headers: switch (booru) {
        final Sankaku s => s.headers,
        _ => null,
      },
    );
  },
);

final sankakuPostRepoProvider =
    Provider.family<PostRepository<SankakuPost>, BooruConfig>(
  (ref, config) {
    final client = ref.watch(sankakuClientProvider(config));

    return PostRepositoryBuilder(
      getSettings: () async => ref.read(imageListingSettingsProvider),
      fetch: (tags, page, {limit}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
          limit: limit,
        );

        return posts
            .map((e) {
              final hasParent = e.parentId != null;
              final hasChilren = e.hasChildren ?? false;
              final hasParentOrChildren = hasParent || hasChilren;
              final artistTags = e.tags
                      ?.where((e) =>
                          TagCategory.fromLegacyId(e.type) ==
                          TagCategory.artist())
                      .map((e) => Tag(
                            name: e.tagName ?? '????',
                            category: TagCategory.artist(),
                            postCount: e.postCount ?? 0,
                          ))
                      .toList() ??
                  [];

              final characterTags = e.tags
                      ?.where((e) =>
                          TagCategory.fromLegacyId(e.type) ==
                          TagCategory.character())
                      .map((e) => Tag(
                            name: e.tagName ?? '????',
                            category: TagCategory.character(),
                            postCount: e.postCount ?? 0,
                          ))
                      .toList() ??
                  [];

              final copyrightTags = e.tags
                      ?.where((e) =>
                          TagCategory.fromLegacyId(e.type) ==
                          TagCategory.copyright())
                      .map((e) => Tag(
                            name: e.tagName ?? '????',
                            category: TagCategory.copyright(),
                            postCount: e.postCount ?? 0,
                          ))
                      .toList() ??
                  [];
              final timestamp = e.createdAt?.s;

              return SankakuPost(
                id: e.id ?? 0,
                thumbnailImageUrl: e.previewUrl ?? '',
                sampleImageUrl: e.sampleUrl ?? '',
                originalImageUrl: e.fileUrl ?? '',
                tags:
                    e.tags?.map((e) => e.tagName).whereNotNull().toSet() ?? {},
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
                artistDetailsTags: artistTags,
                characterDetailsTags: characterTags,
                copyrightDetailsTags: copyrightTags,
                createdAt: timestamp != null
                    ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
                    : null,
                uploaderId: e.author?.id,
                metadata: PostMetadata(
                  page: page,
                  search: tags.join(' '),
                ),
              );
            })
            .toList()
            .toResult();
      },
    );
  },
);

final sankakuAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfig>((ref, config) {
  final client = ref.watch(sankakuClientProvider(config));

  return AutocompleteRepositoryBuilder(
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
    autocomplete: (query) =>
        client.getAutocomplete(query: query).then((value) => value
            .map((e) => AutocompleteData(
                  label: e.name?.toLowerCase().replaceAll('_', ' ') ?? '???',
                  value: e.tagName ?? '???',
                  postCount: e.count,
                  category: e.type?.toString(),
                ))
            .toList()),
  );
});

final sankakuArtistPostRepo =
    Provider.family<PostRepository<SankakuPost>, BooruConfig>((ref, config) {
  return PostRepositoryCacher(
    keyBuilder: (tags, page, {limit}) =>
        '${tags.split(' ').join('-')}_${page}_$limit',
    repository: ref.watch(sankakuPostRepoProvider(config)),
    cache: LruCacher(capacity: 100),
  );
});

final sankakuArtistPostsProvider = FutureProvider.autoDispose
    .family<List<SankakuPost>, String?>((ref, artistName) async {
  return ref
      .watch(sankakuArtistPostRepo(ref.watchConfig))
      .getPostsFromTagWithBlacklist(
        tag: artistName,
        blacklist: ref.watch(blacklistTagsProvider(ref.watchConfig).future),
      );
});

String? extractFileExtension(String? mimeType) {
  if (mimeType == null) return null;
  final parts = mimeType.split('/');
  return parts.length >= 2 ? '.${parts[1]}' : null;
}
