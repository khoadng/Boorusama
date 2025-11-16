// Package imports:
import 'package:booru_clients/moebooru.dart';

// Project imports:
import '../../../core/posts/post/tags.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import 'types.dart';

MoebooruPost postDtoToPostNoMetadata(PostDto postDto) {
  return postDtoToPost(postDto, null);
}

MoebooruPost postDtoToPost(PostDto postDto, PostMetadata? metadata) {
  final hasChildren = postDto.hasChildren ?? false;
  final hasParent = postDto.parentId != null;
  final hasParentOrChildren = hasChildren || hasParent;

  return MoebooruPost(
    id: postDto.id ?? 0,
    thumbnailImageUrl: postDto.previewUrl ?? '',
    largeImageUrl: postDto.jpegUrl ?? '',
    sampleImageUrl: postDto.sampleUrl ?? '',
    originalImageUrl: postDto.fileUrl ?? '',
    tags: postDto.tags.splitTagString(),
    source: PostSource.from(postDto.source),
    rating: Rating.parse(postDto.rating ?? ''),
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: hasParentOrChildren,
    width: postDto.width?.toDouble() ?? 1,
    height: postDto.height?.toDouble() ?? 1,
    md5: postDto.md5 ?? '',
    fileSize: postDto.fileSize ?? 0,
    format: postDto.fileUrl?.split('.').lastOrNull ?? '',
    score: postDto.score ?? 0,
    createdAt: postDto.createdAt != null
        ? DateTime.fromMillisecondsSinceEpoch(postDto.createdAt! * 1000)
        : null,
    parentId: postDto.parentId,
    uploaderId: postDto.creatorId,
    uploaderName: postDto.author,
    metadata: metadata,
    status: StringPostStatus.tryParse(postDto.status),
  );
}
