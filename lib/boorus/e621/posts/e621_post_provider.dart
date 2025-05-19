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
    getComposer: () => ref.read(tagQueryComposerProvider(config)),
    fetchSingle: (id, {options}) async {
      final numericId = id as NumericPostId?;

      if (numericId == null) return Future.value(null);

      final post = await client.getPost(numericId.value);

      return post != null ? postDtoToPost(post, null) : null;
    },
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
  // Check for 720p sample
  final p720Url = dto.sample?.alternates?.samples?['720p']?.url ?? '';
  if (p720Url.isNotEmpty && p720Url.endsWith('.mp4')) {
    return p720Url;
  }

  // Check for 480p sample
  final p480Url = dto.sample?.alternates?.samples?['480p']?.url ?? '';
  if (p480Url.isNotEmpty && p480Url.endsWith('.mp4')) {
    return p480Url;
  }

  // Check for variants
  final mp4Variant = dto.sample?.alternates?.variants?['mp4']?.url ?? '';
  if (mp4Variant.isNotEmpty && mp4Variant.endsWith('.mp4')) {
    return mp4Variant;
  }

  // Check for original
  final originalUrl = dto.sample?.alternates?.original?.url ?? '';
  if (originalUrl.isNotEmpty &&
      (originalUrl.endsWith('.mp4') || originalUrl.endsWith('.webm'))) {
    return originalUrl;
  }

  return '';
}
