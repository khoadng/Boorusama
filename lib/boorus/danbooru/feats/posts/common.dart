// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/clients/danbooru/types/post_dto.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/string.dart';
import 'danbooru_post.dart';
import 'post_variant.dart';

// convert a BooruConfig and an orignal tag list to List<String>
List<String> getTags(BooruConfig booruConfig, List<String> tags) {
  final ratingTag = booruFilterConfigToDanbooruTag(booruConfig.ratingFilter);
  final deletedStatusTag = booruConfigDeletedBehaviorToDanbooruTag(
    booruConfig.deletedItemBehavior,
  );
  return [
    ...tags,
    if (ratingTag != null) ratingTag,
    if (deletedStatusTag != null) deletedStatusTag,
  ];
}

DanbooruPost postDtoToPost(
  PostDto dto,
) {
  try {
    return DanbooruPost(
      id: dto.id!,
      thumbnailImageUrl: dto.previewFileUrl ?? '',
      sampleImageUrl: dto.largeFileUrl ?? '',
      originalImageUrl: dto.fileUrl ?? '',
      copyrightTags: dto.tagStringCopyright.splitByWhitespace(),
      characterTags: dto.tagStringCharacter.splitByWhitespace(),
      artistTags: dto.tagStringArtist.splitByWhitespace(),
      generalTags: dto.tagStringGeneral.splitByWhitespace(),
      metaTags: dto.tagStringMeta.splitByWhitespace(),
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
      rating: mapStringToRating(dto.rating ?? 's'),
      fileSize: dto.fileSize ?? 0,
      isBanned: dto.isBanned ?? false,
      hasChildren: dto.hasChildren ?? false,
      parentId: dto.parentId,
      hasLarge: dto.hasLarge ?? false,
      duration: dto.mediaAsset?.duration ?? 0,
      variants:
          dto.mediaAsset?.variants?.map(variantDtoToVariant).toList() ?? [],
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
