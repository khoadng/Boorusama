// Package imports:
import 'package:booru_clients/e621.dart';
import 'package:path/path.dart' show extension;

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import 'types.dart';

E621Post? postDtoToPostNoMetadata(PostDto dto) {
  return postDtoToPost(dto, null);
}

E621Post? postDtoToPost(PostDto dto, PostMetadata? metadata) {
  final file = dto.file;

  if (file == null || file.url == null) return null;

  final videoVariantsList = _parseVideoVariants(dto);
  final videoVariants = {
    for (final variant in videoVariantsList) variant.type: variant,
  };
  final videoUrl = extractSampleVideoUrl(videoVariants);
  final videoFormat = videoUrl.isNotEmpty
      ? extension(videoUrl).substring(1)
      : '';

  final format = videoFormat.isNotEmpty ? videoFormat : file.ext ?? '';
  final isGif = format.toLowerCase() == 'gif' || format.toLowerCase() == '.gif';
  final previewUrl = dto.preview?.url ?? '';
  final sampleUrl = dto.sample?.url;
  final originalUrl = dto.file?.url ?? '';

  return E621Post(
    id: dto.id ?? 0,
    source: PostSource.from(dto.sources?.firstOrNull),
    thumbnailImageUrl: previewUrl,
    sampleImageUrl: isGif ? originalUrl : sampleUrl ?? originalUrl,
    originalImageUrl: originalUrl,
    rating: Rating.parse(dto.rating),
    hasComment: dto.commentCount != null && dto.commentCount! > 0,
    isTranslated: dto.hasNotes ?? false,
    hasParentOrChildren:
        dto.relationships?.hasChildren ??
        false || dto.relationships?.parentId != null,
    format: format,
    videoUrl: videoUrl,
    width: file.width?.toDouble() ?? 0,
    height: file.height?.toDouble() ?? 0,
    md5: file.md5 ?? '',
    fileSize: file.size ?? 0,
    score: dto.score?.total ?? 0,
    createdAt: DateTime.tryParse(dto.createdAt ?? '') ?? DateTime.now(),
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
    uploaderName: dto.uploaderName,
    metadata: metadata,
    videoVariants: videoVariants,
    status: E621PostStatus.from(
      isPending: dto.flags?.pending,
      isFlagged: dto.flags?.flagged,
      isDeleted: dto.flags?.deleted,
    ),
  );
}

String extractSampleVideoUrl(
  Map<E621VideoVariantType, E621VideoVariant> variants,
) {
  if (variants.isEmpty) return '';

  return variants[E621VideoVariantType.v720p]?.url ??
      variants[E621VideoVariantType.v480p]?.url ??
      variants[E621VideoVariantType.sample]?.url ??
      variants[E621VideoVariantType.original]?.url ??
      '';
}

List<E621VideoVariant> _parseVideoVariants(PostDto dto) =>
    switch (dto.sample?.alternates) {
      null => [],
      final alternates => [
        if (alternates.original case final original?)
          _parseVideoVariant(
            original,
          ).copyWith(type: E621VideoVariantType.original),
        if (alternates.variants case final variants?) ...[
          if (variants['mp4'] case final mp4?)
            _parseVideoVariant(
              mp4,
            ).copyWith(type: E621VideoVariantType.sample),
        ],
        if (alternates.samples case final samples?) ...[
          if (samples['720p'] case final p720?)
            _parseVideoVariant(
              p720,
            ).copyWith(type: E621VideoVariantType.v720p),
          if (samples['480p'] case final p480?)
            _parseVideoVariant(
              p480,
            ).copyWith(type: E621VideoVariantType.v480p),
        ],
      ],
    };

E621VideoVariant _parseVideoVariant(E621VideoInfoDto dto) => E621VideoVariant(
  width: dto.width ?? 0,
  height: dto.height ?? 0,
  url: dto.url ?? '',
  size: dto.size ?? 0,
  codec: dto.codec ?? '',
  fps: dto.fps ?? 0,
  type: E621VideoVariantType.original,
);
