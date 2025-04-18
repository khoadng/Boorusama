// Package imports:
import 'package:booru_clients/e621.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/configs/ref.dart';
import '../../../core/foundation/path.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/posts/rating/rating.dart';
import '../../../core/posts/sources/source.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/settings/providers.dart';
import '../e621.dart';
import 'posts.dart';

final e621PostRepoProvider =
    Provider.family<PostRepository<E621Post>, BooruConfigSearch>((ref, config) {
  final client = ref.watch(e621ClientProvider(config.auth));

  return PostRepositoryBuilder(
    getComposer: () => ref.read(currentTagQueryComposerProvider),
    fetch: (tags, page, {limit, options}) async {
      final data = await client
          .getPosts(
            page: page,
            tags: tags,
            limit: limit,
          )
          .then(
            (value) => value
                .map(
                  (e) => postDtoToPost(
                    e,
                    PostMetadata(
                      page: page,
                      search: tags.join(' '),
                      limit: limit,
                    ),
                  ),
                )
                .toList(),
          );

      if (options?.cascadeRequest ?? true) {
        ref.read(favoritesProvider(config.auth).notifier).preload(data);
      }

      return data.toResult();
    },
    getSettings: () async => ref.read(imageListingSettingsProvider),
  );
});

final e621PopularPostRepoProvider =
    Provider.family<E621PopularRepository, BooruConfigAuth>((ref, config) {
  return E621PopularRepositoryApi(
    ref.watch(e621ClientProvider(config)),
    ref.watchConfig,
  );
});

E621Post postDtoToPostNoMetadata(PostDto dto) {
  return postDtoToPost(dto, null);
}

E621Post postDtoToPost(PostDto dto, PostMetadata? metadata) {
  final videoUrl = extractSampleVideoUrl(dto);
  final format = videoUrl.isNotEmpty ? extension(videoUrl).substring(1) : '';

  return E621Post(
    id: dto.id ?? 0,
    source: PostSource.from(dto.sources?.firstOrNull),
    thumbnailImageUrl: dto.preview?.url ?? '',
    sampleImageUrl: dto.sample?.url ?? '',
    originalImageUrl: dto.file?.url ?? '',
    rating: mapStringToRating(dto.rating),
    hasComment: dto.commentCount != null && dto.commentCount! > 0,
    isTranslated: dto.hasNotes ?? false,
    hasParentOrChildren: dto.relationships?.hasChildren ??
        false || dto.relationships?.parentId != null,
    format: format.isEmpty ? dto.file?.ext ?? '' : format,
    videoUrl: videoUrl,
    width: dto.file?.width?.toDouble() ?? 0,
    height: dto.file?.height?.toDouble() ?? 0,
    md5: dto.file?.md5 ?? '',
    fileSize: dto.file?.size ?? 0,
    score: dto.score?.total ?? 0,
    createdAt: DateTime.parse(dto.createdAt ?? ''),
    duration: dto.duration ?? 0,
    characterTags: Set<String>.from(dto.tags?['character'] ?? {}).toSet(),
    copyrightTags: Set<String>.from(dto.tags?['copyright'] ?? {}).toSet(),
    artistTags: Set<String>.from(dto.tags?['artist'] ?? {}).toSet(),
    generalTags: Set<String>.from(dto.tags?['general'] ?? {}).toSet(),
    metaTags: Set<String>.from(dto.tags?['meta'] ?? {}).toSet(),
    speciesTags: Set<String>.from(dto.tags?['species'] ?? {}).toSet(),
    loreTags: Set<String>.from(dto.tags?['lore'] ?? {}).toSet(),
    invalidTags: Set<String>.from(dto.tags?['invalid'] ?? {}).toSet(),
    upScore: dto.score?.up ?? 0,
    downScore: dto.score?.down ?? 0,
    favCount: dto.favCount ?? 0,
    isFavorited: dto.isFavorited ?? false,
    sources: dto.sources?.map(PostSource.from).toList() ?? [],
    description: dto.description ?? '',
    parentId: dto.relationships?.parentId,
    uploaderId: dto.uploaderId,
    metadata: metadata,
  );
}

String extractSampleVideoUrl(PostDto dto) {
  final p720 = dto.sample?.alternates?['720p']?.urls
          ?.firstWhereOrNull((e) => e.endsWith('.mp4')) ??
      '';

  final p480 = dto.sample?.alternates?['480p']?.urls
          ?.firstWhereOrNull((e) => e.endsWith('.mp4')) ??
      '';

  final pOriginal = dto.sample?.alternates?['original']?.urls
          ?.firstWhereOrNull((e) => e.endsWith('.mp4')) ??
      '';

  return p720.isNotEmpty
      ? p720
      : p480.isNotEmpty
          ? p480
          : pOriginal;
}
