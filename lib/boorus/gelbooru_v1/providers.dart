part of 'gelbooru_v1.dart';

final gelbooruV1PostRepoProvider = Provider.family<PostRepository, BooruConfig>(
  (ref, config) {
    final client = ref.watch(gelbooruV1ClientProvider(config));

    return PostRepositoryBuilder(
      getSettings: () async => ref.read(settingsProvider),
      fetch: (tags, page, {limit}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
        );

        return posts
            .map((e) => SimplePost(
                  id: e.id ?? 0,
                  thumbnailImageUrl: sanitizedUrl(e.previewUrl ?? ''),
                  sampleImageUrl: sanitizedUrl(e.sampleUrl ?? ''),
                  originalImageUrl: sanitizedUrl(e.fileUrl ?? ''),
                  tags: e.tags?.split(' ').toSet() ?? {},
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
                  uploaderId: null,
                ))
            .toList();
      },
    );
  },
);

final gelbooruV1ClientProvider =
    Provider.family<GelbooruV1Client, BooruConfig>((ref, booruConfig) {
  final dio = newDio(ref.watch(dioArgsProvider(booruConfig)));

  return GelbooruV1Client(
    baseUrl: booruConfig.url,
    dio: dio,
  );
});
