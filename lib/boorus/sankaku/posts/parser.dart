// Package imports:
import 'package:booru_clients/sankaku.dart';
import 'package:coreutils/coreutils.dart';

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import '../../../core/tags/tag/types.dart';
import '../tags/categories.dart';
import 'types.dart';

List<Tag> sankakuTagDtosToTags(List<TagDto>? tags) {
  if (tags == null) return const [];

  final parsed = <Object, Tag>{};
  for (final dto in tags) {
    final name = dto.tagName;
    if (name == null || name.isEmpty) continue;

    final key = switch (dto.id) {
      final id? => (id: id),
      null => (name: name, type: dto.type),
    };
    final tag = Tag(
      name: name,
      category: sankakuTagCategoryFromApiId(dto.type),
      postCount: dto.postCount ?? dto.count ?? 0,
    );
    final existing = parsed[key];

    if (existing == null) {
      parsed[key] = tag;
    } else if (tag.postCount > existing.postCount) {
      parsed[key] = existing.copyWith(null, null, tag.postCount);
    }
  }

  return parsed.values.toList(growable: false);
}

SankakuPost postDtoToPost(
  PostDto e,
  PostIdGenerator idGenerator,
  PostMetadata? metadata,
) {
  final hasParent = e.parentId != null;
  final hasChilren = e.hasChildren ?? false;
  final hasParentOrChildren = hasParent || hasChilren;
  final detailedTags = sankakuTagDtosToTags(e.tags);

  final timestamp = e.createdAt?.s;

  final (id, sankakuId) = switch (e.id) {
    // No id, so we generate a pseudo id for shared post plumbing.
    null => (idGenerator.generateId(), null),
    // Int id, which means they reverted back to int id
    IntId i => (i.value, i),
    // String id, which means they are using string id
    StringId s => (idGenerator.generateId(), s),
  };

  return SankakuPost(
    id: id,
    sankakuId: sankakuId,
    isFavorited: e.isFavorited ?? false,
    favoriteCount: e.favCount ?? 0,
    thumbnailImageUrl: e.previewUrl ?? '',
    sampleImageUrl: e.sampleUrl ?? '',
    originalImageUrl: e.fileUrl ?? '',
    rating: Rating.parse(e.rating),
    hasComment: e.hasComments ?? false,
    isTranslated: false,
    hasParentOrChildren: hasParentOrChildren,
    source: PostSource.from(e.source),
    score: e.totalScore ?? 0,
    duration: e.videoDuration ?? 0,
    fileSize: e.fileSize ?? 0,
    format:
        extractFileExtension(
          e.fileType,
          fileUrl: e.fileUrl,
        ) ??
        '',
    hasSound: null,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5 ?? '',
    videoThumbnailUrl: e.previewUrl ?? '',
    videoUrl: e.fileUrl ?? '',
    width: e.width?.toDouble() ?? 0,
    detailedTags: detailedTags,
    createdAt: timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
        : null,
    // uploaderId: e.author?.id,
    uploaderId: 0, // The id is now a string
    uploaderName: e.author?.name,
    metadata: metadata,
    status: StringPostStatus.tryParse(e.status),
  );
}

String? extractFileExtension(
  String? mimeType, {
  String? fileUrl,
}) {
  if (mimeType == null) {
    if (fileUrl == null) return null;

    final ext = urlExtension(fileUrl);

    return ext;
  }

  final parts = mimeType.split('/');
  return parts.length >= 2 ? '.${parts[1]}' : null;
}
