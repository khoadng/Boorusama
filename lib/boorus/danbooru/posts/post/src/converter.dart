// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../../../../../core/posts/post/post.dart';
import '../../../../../core/posts/post/tags.dart';
import '../../../../../core/posts/rating/rating.dart';
import '../../../../../core/posts/sources/source.dart';
import 'danbooru_post.dart';
import 'post_variant.dart';

DanbooruPost postDtoToPostNoMetadata(PostDto dto) => postDtoToPost(dto, null);

DanbooruPost postDtoToPost(
  PostDto dto,
  PostMetadata? metadata,
) {
  try {
    return DanbooruPost(
      id: dto.id!,
      thumbnailImageUrl: dto.previewFileUrl ?? '',
      sampleImageUrl: dto.largeFileUrl ?? '',
      originalImageUrl: dto.fileUrl ?? '',
      tags: dto.tagString.splitTagString(),
      copyrightTags: dto.tagStringCopyright.splitTagString(),
      characterTags: dto.tagStringCharacter.splitTagString(),
      artistTags: dto.tagStringArtist.splitTagString(),
      generalTags: dto.tagStringGeneral.splitTagString(),
      metaTags: dto.tagStringMeta.splitTagString(),
      width: dto.imageWidth?.toDouble() ?? 0.0,
      height: dto.imageHeight?.toDouble() ?? 0.0,
      format: dto.fileExt ?? 'jpg',
      md5: dto.md5 ?? '',
      lastCommentAt: dto.lastCommentedAt != null
          ? DateTime.parse(dto.lastCommentedAt!)
          : null,
      source: PostSource.from(
        dto.source,
        pixivId: dto.pixivId,
      ),
      createdAt: dto.createdAt != null
          ? DateTime.parse(dto.createdAt!)
          : DateTime.now(),
      score: dto.score ?? 0,
      upScore: dto.upScore ?? 0,
      downScore: dto.downScore ?? 0,
      favCount: dto.favCount ?? 0,
      uploaderId: dto.uploaderId ?? 0,
      approverId: dto.approverId,
      rating: mapStringToRating(dto.rating ?? 's'),
      fileSize: dto.fileSize ?? 0,
      isBanned: dto.isBanned ?? false,
      hasChildren: dto.hasChildren ?? false,
      parentId: dto.parentId,
      hasLarge: dto.hasLarge ?? false,
      duration: dto.mediaAsset?.duration ?? 0,
      variants:
          dto.mediaAsset?.variants?.map(variantDtoToVariant).toList() ?? [],
      pixelHash: dto.mediaAsset?.pixelHash ?? '',
      metadata: metadata,
    );
  } catch (e) {
    return DanbooruPost.empty();
  }
}

PostVariant variantDtoToVariant(VariantDto dto) => PostVariant(
      url: dto.url ?? '',
      width: dto.width ?? 0,
      height: dto.height ?? 0,
      type: mapStringToPostQualityType(dto.type) ?? PostQualityType.sample,
      fileExt: dto.fileExt ?? 'jpg',
    );
