// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:path/path.dart' as path;

// Project imports:
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/tags.dart';
import '../../../core/posts/rating/rating.dart';
import '../../../core/posts/sources/source.dart';
import 'types.dart';

GelbooruV2Post gelbooruV2PostDtoToGelbooruPostNoMetadata(PostV2Dto dto) =>
    gelbooruV2PostDtoToGelbooruPost(dto, null);

GelbooruV2Post gelbooruV2PostDtoToGelbooruPost(
  PostV2Dto dto,
  PostMetadata? metadata,
) {
  return GelbooruV2Post(
    id: dto.id!,
    thumbnailImageUrl: dto.previewUrl ?? '',
    sampleImageUrl: dto.sampleUrl ?? dto.fileUrl ?? '',
    originalImageUrl: dto.fileUrl ?? '',
    tags: dto.tags.splitTagString(),
    width: dto.width?.toDouble() ?? 0,
    height: dto.height?.toDouble() ?? 0,
    format: path.extension(dto.fileUrl ?? 'foo.png').substring(1),
    source: PostSource.from(dto.source),
    rating: mapStringToRating(dto.rating ?? 'safe'),
    md5: dto.hash ?? '',
    hasComment: dto.commentCount != null && dto.commentCount! > 0,
    hasParentOrChildren: dto.parentId != null && dto.parentId != 0,
    fileSize: 0,
    score: dto.score ?? 0,
    createdAt: null,
    parentId: dto.parentId != 0 ? dto.parentId : null,
    uploaderId: null,
    uploaderName: dto.owner,
    hasNotes: _checkIfHasNotes(dto),
    metadata: metadata,
  );
}

bool _checkIfHasNotes(PostV2Dto dto) {
  // if data contains hasNotes, return it
  if (dto.hasNotes != null) {
    return dto.hasNotes ?? false;
  }

  // check if tags contains 'translated' and not contains 'hard_translated'
  final tags = dto.tags.splitTagString();
  return tags.contains('translated') && !tags.contains('hard_translated');
}
