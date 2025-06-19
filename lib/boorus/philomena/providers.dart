// Package imports:
import 'package:booru_clients/philomena.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/configs/config.dart';
import '../../core/http/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/sources/source.dart';
import '../../core/search/queries/providers.dart';
import '../../core/settings/providers.dart';
import 'philomena_post.dart';

final philomenaClientProvider =
    Provider.family<PhilomenaClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(dioProvider(config));

    return PhilomenaClient(
      dio: dio,
      baseUrl: config.url,
      apiKey: config.apiKey,
    );
  },
);

final philomenaPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>((ref, config) {
  final client = ref.watch(philomenaClientProvider(config.auth));

  return PostRepositoryBuilder(
    getComposer: () => ref.read(tagQueryComposerProvider(config)),
    getSettings: () async => ref.read(imageListingSettingsProvider),
    fetchSingle: (id, {options}) async {
      final numericId = id as NumericPostId?;

      if (numericId == null) return Future.value(null);

      final post = await client.getImage(numericId.value);

      return post != null ? _postDtoToPost(post, null) : null;
    },
    fetch: (tags, page, {limit, options}) async {
      final isEmpty = tags.join(' ').isEmpty;

      final posts = await client.getImages(
        tags: isEmpty ? ['*'] : tags,
        page: page,
        perPage: limit,
      );

      return posts.images
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
          .toResult(total: posts.count);
    },
  );
});

PhilomenaPost _postDtoToPost(ImageDto e, PostMetadata? metadata) {
  final isVideo = e.mimeType?.contains('video') ?? false;

  return PhilomenaPost(
    id: e.id ?? 0,
    thumbnailImageUrl: isVideo
        ? _parseVideoThumbnail(e) ?? ''
        : e.representations?.thumb ?? '',
    sampleImageUrl: e.representations?.medium ?? '',
    originalImageUrl: e.representations?.full ?? '',
    tags: e.tags?.map((e) => e.replaceAll('+', '_')).toSet() ?? {},
    rating: Rating.general,
    commentCount: e.commentCount ?? 0,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.from(e.sourceUrl),
    score: e.score ?? 0,
    duration: e.duration ?? 0,
    fileSize: e.size ?? 0,
    format: e.format ?? '',
    hasSound: e.tags?.contains('sound'),
    height: e.height?.toDouble() ?? 0,
    md5: e.sha512Hash ?? '',
    videoThumbnailUrl: isVideo ? _parseVideoThumbnail(e) ?? '' : '',
    videoUrl: e.representations?.full ?? '',
    width: e.width?.toDouble() ?? 0,
    description: e.description ?? '',
    createdAt: e.createdAt,
    favCount: e.faves ?? 0,
    upvotes: e.upvotes ?? 0,
    downvotes: e.downvotes ?? 0,
    representation: PhilomenaRepresentation(
      full: e.representations?.full ?? '',
      large: e.representations?.large ?? '',
      medium: e.representations?.medium ?? '',
      small: e.representations?.small ?? '',
      tall: e.representations?.tall ?? '',
      thumb: e.representations?.thumb ?? '',
      thumbSmall: e.representations?.thumbSmall ?? '',
      thumbTiny: e.representations?.thumbTiny ?? '',
    ),
    uploaderId: e.uploaderId,
    uploaderName: e.uploader,
    metadata: metadata,
  );
}

String? _parseVideoThumbnail(ImageDto e) =>
    e.representations?.thumb.toOption().fold(
          () => '',
          (url) => '${url.substring(0, url.lastIndexOf("/") + 1)}thumb.gif',
        );

const _kSlugReplacement = [
  ['-colon-', ':'],
  ['-dash-', '-'],
  ['-fwslash-', '/'],
  ['-bwslash-', r'\'],
  ['-dot-', '.'],
  ['-plus-', '+'],
];

final philomenaAutoCompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(philomenaClientProvider(config));

  return AutocompleteRepositoryBuilder(
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v2',
    autocomplete: (query) => switch (query.text.length) {
      0 || 1 => Future.value([]),
      _ => client.getTags(query: '$query*').then(
            (value) => value
                .map(
                  (e) => AutocompleteData(
                    label: e.name ?? '???',
                    value: e.name?.replaceAll(' ', '_') ??
                        e.slug.toOption().fold(
                              () => '???',
                              (slug) => _kSlugReplacement.fold(
                                slug,
                                (s, e) => s.replaceAll(e[1], e[0]),
                              ),
                            ),
                    antecedent: e.aliasedTag,
                    category: e.category ?? '',
                    postCount: e.images,
                  ),
                )
                .toList(),
          ),
    },
  );
});
