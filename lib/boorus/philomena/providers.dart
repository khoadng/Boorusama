// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/philomena/philomena_post.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/philomena/philomena_client.dart';
import 'package:boorusama/clients/philomena/types/image_dto.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/functional.dart';

final philomenaClientProvider = Provider.family<PhilomenaClient, BooruConfig>(
  (ref, config) {
    final dio = newDio(ref.watch(dioArgsProvider(config)));

    return PhilomenaClient(
      dio: dio,
      baseUrl: config.url,
      apiKey: config.apiKey,
    );
  },
);

final philomenaPostRepoProvider =
    Provider.family<PostRepository, BooruConfig>((ref, config) {
  final client = ref.watch(philomenaClientProvider(config));

  return PostRepositoryBuilder(
    getSettings: () async => ref.read(settingsProvider),
    fetch: (tags, page, {limit}) async {
      final isEmpty = tags.join(' ').isEmpty;

      final posts = await client.getImages(
        tags: isEmpty ? ['*'] : tags,
        page: page,
        perPage: limit,
      );

      return posts.map((e) {
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
          metadata: PostMetadata(
            page: page,
            search: tags.join(' '),
          ),
        );
      }).toList();
    },
  );
});

String? _parseVideoThumbnail(ImageDto e) =>
    e.representations?.thumb?.toOption().fold(
          () => '',
          (url) => '${url.substring(0, url.lastIndexOf("/") + 1)}thumb.gif',
        );

const _kSlugReplacement = [
  ["-colon-", ":"],
  ["-dash-", "-"],
  ["-fwslash-", "/"],
  ["-bwslash-", "\\"],
  ["-dot-", "."],
  ["-plus-", "+"]
];

final philomenaAutoCompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfig>((ref, config) {
  final client = ref.watch(philomenaClientProvider(config));

  return AutocompleteRepositoryBuilder(
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v2',
    autocomplete: (query) => switch (query.length) {
      0 || 1 => Future.value([]),
      _ => client.getTags(query: '$query*').then((value) => value
          .map((e) => AutocompleteData(
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
              ))
          .toList()),
    },
  );
});
