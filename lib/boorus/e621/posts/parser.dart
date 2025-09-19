// Package imports:
import 'package:booru_clients/e621.dart';
import 'package:path/path.dart' show extension;

// Project imports:
import '../../../core/posts/post/post.dart';
import '../../../core/posts/rating/rating.dart';
import '../../../core/posts/sources/src/source.dart';
import 'types.dart';

E621Post? postDtoToPostNoMetadata(PostDto dto) {
  return postDtoToPost(dto, null);
}

E621Post? postDtoToPost(PostDto dto, PostMetadata? metadata) {
  final file = dto.file;

  if (file == null || file.url == null) return null;

  final videoUrl = extractSampleVideoUrl(dto);
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
    rating: mapStringToRating(dto.rating),
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
