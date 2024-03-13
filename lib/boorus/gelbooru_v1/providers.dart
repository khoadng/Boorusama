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
            .map((e) => GelbooruV1Post(
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
                  uploaderId: null,
                  createdAt: null,
                  uploaderName: null,
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
  });

  @override
  String getLink(String baseUrl) {
    return baseUrl.endsWith('/')
        ? '${baseUrl}index.php?page=post&s=view&id=$id'
        : '$baseUrl/index.php?page=post&s=view&id=$id';
  }
}
