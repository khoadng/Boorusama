part of 'sankaku.dart';

final sankakuClientProvider = Provider.family<SankakuClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(dioProvider(config));
    final booru = ref.watch(sankakuProvider);

    return SankakuClient.extended(
      dio: dio,
      baseUrl: config.url,
      username: config.login,
      password: config.apiKey,
      headers: booru.headers,
    );
  },
);

final sankakuProvider = Provider<Sankaku>(
  (ref) {
    final booruDb = ref.watch(booruDbProvider);
    final booru = booruDb.getBooru<Sankaku>();

    if (booru == null) {
      throw Exception('Booru not found for type: ${BooruType.sankaku}');
    }

    return booru;
  },
);

final sankakuPseudoIdGeneratorProvider = Provider((ref) {
  return PostIdGenerator();
});

final sankakuPostRepoProvider =
    Provider.family<PostRepository<SankakuPost>, BooruConfigSearch>(
  (ref, config) {
    final client = ref.watch(sankakuClientProvider(config.auth));
    final idGenerator = ref.watch(sankakuPseudoIdGeneratorProvider);

    return PostRepositoryBuilder(
      getComposer: () => ref.read(currentTagQueryComposerProvider),
      getSettings: () async => ref.read(imageListingSettingsProvider),
      fetchSingle: (id, {options}) async {
        final stringId = id as StringPostId?;

        if (stringId == null) return Future.value(null);

        final post = await client.getPost(id: stringId.value);

        return post != null ? _postDtoToPost(post, idGenerator, null) : null;
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
                idGenerator,
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
    );
  },
);

SankakuPost _postDtoToPost(
  PostDto e,
  PostIdGenerator idGenerator,
  PostMetadata? metadata,
) {
  final hasParent = e.parentId != null;
  final hasChilren = e.hasChildren ?? false;
  final hasParentOrChildren = hasParent || hasChilren;
  final artistTags = e.tags
          ?.where(
            (e) => TagCategory.fromLegacyId(e.type) == TagCategory.artist(),
          )
          .map(
            (e) => Tag(
              name: e.tagName ?? '????',
              category: TagCategory.artist(),
              postCount: e.postCount ?? 0,
            ),
          )
          .toList() ??
      [];

  final characterTags = e.tags
          ?.where(
            (e) => TagCategory.fromLegacyId(e.type) == TagCategory.character(),
          )
          .map(
            (e) => Tag(
              name: e.tagName ?? '????',
              category: TagCategory.character(),
              postCount: e.postCount ?? 0,
            ),
          )
          .toList() ??
      [];

  final copyrightTags = e.tags
          ?.where(
            (e) => TagCategory.fromLegacyId(e.type) == TagCategory.copyright(),
          )
          .map(
            (e) => Tag(
              name: e.tagName ?? '????',
              category: TagCategory.copyright(),
              postCount: e.postCount ?? 0,
            ),
          )
          .toList() ??
      [];

  final generalTags = e.tags
          ?.where(
            (e) => TagCategory.fromLegacyId(e.type) == TagCategory.general(),
          )
          .map(
            (e) => Tag(
              name: e.tagName ?? '????',
              category: TagCategory.general(),
              postCount: e.postCount ?? 0,
            ),
          )
          .toList() ??
      [];

  final metaTags = e.tags
          ?.where(
            (e) => TagCategory.fromLegacyId(e.type) == TagCategory.meta(),
          )
          .map(
            (e) => Tag(
              name: e.tagName ?? '????',
              category: TagCategory.meta(),
              postCount: e.postCount ?? 0,
            ),
          )
          .toList() ??
      [];

  final timestamp = e.createdAt?.s;

  // They changed the id to a string, so a workaround is needed until i can figure out a better way
  // This workaround is just generating an autoincrement id to make the filtering work
  // Update: They are reverting the id back to an int, not sure if they changed their mind again so i will keep this workaround
  final (id, sankakuId) = switch (e.id) {
    // No id, so we generate pseudo id and a dummy string id
    null => (idGenerator.generateId(), ''),
    // Int id, which means they reverted back to int id
    IntId i => (i.value, ''),
    // String id, which means they are using string id
    StringId s => (idGenerator.generateId(), s.value),
  };

  return SankakuPost(
    id: id,
    sankakuId: sankakuId,
    thumbnailImageUrl: e.previewUrl ?? '',
    sampleImageUrl: e.sampleUrl ?? '',
    originalImageUrl: e.fileUrl ?? '',
    tags: e.tags?.map((e) => e.tagName).nonNulls.toSet() ?? {},
    rating: mapStringToRating(e.rating),
    hasComment: e.hasComments ?? false,
    isTranslated: false,
    hasParentOrChildren: hasParentOrChildren,
    source: PostSource.from(e.source),
    score: e.totalScore ?? 0,
    duration: e.videoDuration ?? 0,
    fileSize: e.fileSize ?? 0,
    format: extractFileExtension(
          e.fileType,
          fileUrl: e.fileUrl,
        ) ??
        '',
    hasSound: null,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5 ?? '',
    videoThumbnailUrl: e.previewUrl ?? '',
    videoUrl: e.fileUrl ?? '',
    width: e.width?.toDouble() ?? 0,
    artistDetailsTags: artistTags,
    characterDetailsTags: characterTags,
    copyrightDetailsTags: copyrightTags,
    generalDetailsTags: generalTags,
    metaDetailsTags: metaTags,
    createdAt: timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
        : null,
    // uploaderId: e.author?.id,
    uploaderId: 0, // The id is now a string
    uploaderName: e.author?.name,
    metadata: metadata,
  );
}

final sankakuAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(sankakuClientProvider(config));

  return AutocompleteRepositoryBuilder(
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
    autocomplete: (query) => client.getAutocomplete(query: query).then(
          (value) => value.map(
            (e) {
              final alias = e.aliasOf;

              // if alias is available, we use the alias name instead and point to the original tag
              return alias != null
                  ? AutocompleteData(
                      label:
                          alias.tagName?.toLowerCase().replaceAll('_', ' ') ??
                              '???',
                      value: alias.tagName ?? '???',
                      postCount: alias.postCount,
                      category: alias.type?.toString(),
                      antecedent: e.tagName,
                    )
                  : AutocompleteData(
                      label:
                          e.name?.toLowerCase().replaceAll('_', ' ') ?? '???',
                      value: e.tagName ?? '???',
                      postCount: e.count,
                      category: e.type?.toString(),
                    );
            },
          ).toList(),
        ),
  );
});

final sankakuArtistPostRepo =
    Provider.family<PostRepository<SankakuPost>, BooruConfigSearch>(
        (ref, config) {
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
      .watch(sankakuArtistPostRepo(ref.watchConfigSearch))
      .getPostsFromTagWithBlacklist(
        tag: artistName,
        blacklist: ref.watch(currentBlacklistTagsProvider.future),
      );
});

String? extractFileExtension(
  String? mimeType, {
  String? fileUrl,
}) {
  if (mimeType == null) {
    if (fileUrl == null) return null;

    final ext = sanitizedExtension(fileUrl);

    return ext;
  }

  final parts = mimeType.split('/');
  return parts.length >= 2 ? '.${parts[1]}' : null;
}
