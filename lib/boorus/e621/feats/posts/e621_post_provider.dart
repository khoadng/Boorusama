// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/e621/types/types.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/path.dart';

final e621PostRepoProvider =
    Provider.family<PostRepository<E621Post>, BooruConfig>((ref, config) {
  final client = ref.watch(e621ClientProvider(config));

  return PostRepositoryBuilder(
    fetch: (tags, page, {limit}) async {
      final data = await client
          .getPosts(
            page: page,
            tags: getTags(config, tags),
            limit: limit,
          )
          .then((value) => value.map(postDtoToPost).toList());

      ref.read(e621FavoritesProvider(config).notifier).preload(data);

      return data;
    },
    getSettings: () async => ref.read(settingsProvider),
  );
  // );
});

final e621PopularPostRepoProvider =
    Provider.family<E621PopularRepository, BooruConfig>((ref, config) {
  return E621PopularRepositoryApi(
    ref.watch(e621ClientProvider(config)),
    ref.watchConfig,
    ref.watch(settingsRepoProvider),
  );
});

E621Post postDtoToPost(PostDto dto) {
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
    characterTags: List<String>.from(dto.tags?['character'] ?? []).toList(),
    copyrightTags: List<String>.from(dto.tags?['copyright'] ?? []).toList(),
    artistTags: List<String>.from(dto.tags?['artist'] ?? []).toList(),
    generalTags: List<String>.from(dto.tags?['general'] ?? []).toList(),
    metaTags: List<String>.from(dto.tags?['meta'] ?? []).toList(),
    speciesTags: List<String>.from(dto.tags?['species'] ?? []).toList(),
    loreTags: List<String>.from(dto.tags?['lore'] ?? []).toList(),
    invalidTags: List<String>.from(dto.tags?['invalid'] ?? []).toList(),
    upScore: dto.score?.up ?? 0,
    downScore: dto.score?.down ?? 0,
    favCount: dto.favCount ?? 0,
    isFavorited: dto.isFavorited ?? false,
    sources: dto.sources?.map(PostSource.from).toList() ?? [],
    description: dto.description ?? '',
    parentId: dto.relationships?.parentId,
    uploaderId: dto.uploaderId,
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
