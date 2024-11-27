// Project imports:
import 'package:boorusama/clients/danbooru/types/post_dto.dart';
import 'package:boorusama/core/posts/posts.dart';
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
      tags: dto.tagString?.split(' ').toSet() ?? {},
      copyrightTags: dto.tagStringCopyright?.split(' ').toSet() ?? {},
      characterTags: dto.tagStringCharacter?.split(' ').toSet() ?? {},
      artistTags: dto.tagStringArtist?.split(' ').toSet() ?? {},
      generalTags: dto.tagStringGeneral?.split(' ').toSet() ?? {},
      metaTags: dto.tagStringMeta?.split(' ').toSet() ?? {},
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
