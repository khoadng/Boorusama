// Package imports:
import 'package:booru_clients/anime_pictures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/booru/providers.dart';
import '../../core/configs/config.dart';
import '../../core/downloads/urls.dart';
import '../../core/http/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/sources/source.dart';
import '../../core/search/queries/providers.dart';
import '../../core/settings/providers.dart';
import '../../core/tags/categories/tag_category.dart';
import 'anime_pictures.dart';

final animePicturesClientProvider =
    Provider.family<AnimePicturesClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(dioProvider(config));

    return AnimePicturesClient(
      dio: dio,
      baseUrl: config.url,
      cookie: config.passHash,
    );
  },
);

final animePicturesProvider = Provider<AnimePictures>(
  (ref) {
    final booruDb = ref.watch(booruDbProvider);
    final booru = booruDb.getBooru<AnimePictures>();

    if (booru == null) {
      throw Exception('Booru not found for type: ${BooruType.animePictures}');
    }

    return booru;
  },
);

final animePicturesPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
  (ref, config) {
    final client = ref.watch(animePicturesClientProvider(config.auth));

    return PostRepositoryBuilder(
      getComposer: () => ref.read(currentTagQueryComposerProvider),
      fetch: (tags, page, {limit, options}) async {
        final posts = await client.getPosts(
          tags: tags,
          page: page,
          limit: limit,
        );

        return posts
            .map(
              (e) => dtoToAnimePicturesPost(
                e,
                metadata: PostMetadata(
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

final animePicturesAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(animePicturesClientProvider(config));

    return AutocompleteRepositoryBuilder(
      persistentStorageKey:
          '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      autocomplete: (query) async {
        final tags = await client.getAutocomplete(query: query);

        return tags
            .map(
              (e) => AutocompleteData(
                label: e.t?.toLowerCase() ?? '???',
                value: e.t?.toLowerCase() ?? '???',
                antecedent: e.t2?.toLowerCase(),
                category: animePicturesTagTypeToTagCategory(e.c).name,
              ),
            )
            .toList();
      },
    );
  },
);

final animePicturesDownloadFileUrlExtractorProvider =
    Provider.family<DownloadFileUrlExtractor, BooruConfigAuth>((ref, config) {
  return AnimePicturesDownloadFileUrlExtractor(
    client: ref.watch(animePicturesClientProvider(config)),
  );
});

typedef TopParams = ({
  BooruConfigAuth config,
  bool erotic,
});

final animePicturesDailyPopularProvider = FutureProvider.autoDispose
    .family<List<AnimePicturesPost>, TopParams>((ref, params) async {
  final config = params.config;
  final erotic = params.erotic;

  final client = ref.watch(animePicturesClientProvider(config));

  return client
      .getTopPosts(length: TopLength.day, erotic: erotic)
      .then((value) => value.map(dtoToAnimePicturesPost).toList());
});

final animePicturesWeeklyPopularProvider = FutureProvider.autoDispose
    .family<List<AnimePicturesPost>, TopParams>((ref, params) async {
  final config = params.config;
  final erotic = params.erotic;
  final client = ref.watch(animePicturesClientProvider(config));

  return client
      .getTopPosts(length: TopLength.week, erotic: erotic)
      .then((value) => value.map(dtoToAnimePicturesPost).toList());
});

final animePicturesCurrentUserIdProvider =
    FutureProvider.family<int?, BooruConfigAuth>((ref, config) async {
  final cookie = config.passHash;
  if (cookie == null || cookie.isEmpty) return null;

  final user =
      await ref.watch(animePicturesClientProvider(config)).getProfile();

  return user.id;
});

TagCategory animePicturesTagTypeToTagCategory(AnimePicturesTagType? type) =>
    switch (type) {
      null => TagCategory.general(),
      AnimePicturesTagType.unknown => TagCategory.general(),
      AnimePicturesTagType.character => TagCategory.character(),
      AnimePicturesTagType.reference => TagCategory.general(),
      AnimePicturesTagType.copyrightProduct => TagCategory.copyright(),
      AnimePicturesTagType.author => TagCategory.artist(),
      AnimePicturesTagType.copyrightGame => TagCategory.copyright(),
      AnimePicturesTagType.copyrightOther => TagCategory.copyright(),
      AnimePicturesTagType.object => TagCategory.general(),
    };

AnimePicturesPost dtoToAnimePicturesPost(
  PostDto e, {
  PostMetadata? metadata,
}) {
  return AnimePicturesPost(
    id: e.id ?? 0,
    thumbnailImageUrl: e.mediumPreview ?? '',
    sampleImageUrl: e.bigPreview ?? '',
    originalImageUrl: e.bigPreview ?? '',
    tags: const {},
    rating: switch (e.erotics) {
      EroticLevel.none => Rating.general,
      EroticLevel.light => Rating.sensitive,
      EroticLevel.moderate => Rating.questionable,
      EroticLevel.hard => Rating.explicit,
      null => Rating.unknown,
    },
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.none(),
    score: e.scoreNumber ?? 0,
    duration: 0,
    fileSize: e.size ?? 0,
    format: e.ext ?? '',
    hasSound: null,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5 ?? '',
    videoThumbnailUrl: e.smallPreview ?? '',
    videoUrl: e.bigPreview ?? '',
    width: e.width?.toDouble() ?? 0,
    createdAt: e.pubtime != null ? DateTime.tryParse(e.pubtime!) : null,
    uploaderId: null,
    uploaderName: null,
    metadata: metadata,
    tagsCount: e.tagsCount ?? 0,
  );
}

class AnimePicturesPost extends SimplePost {
  AnimePicturesPost({
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
    required this.tagsCount,
  });

  final int tagsCount;
}
