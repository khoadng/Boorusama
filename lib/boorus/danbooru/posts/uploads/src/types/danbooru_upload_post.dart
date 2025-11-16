// Project imports:
import '../../../../users/user/types.dart';
import '../../../post/types.dart';

class DanbooruUploadPost extends DanbooruPost {
  DanbooruUploadPost({
    required super.id,
    required super.thumbnailImageUrl,
    required super.sampleImageUrl,
    required super.originalImageUrl,
    required super.tags,
    required super.copyrightTags,
    required super.characterTags,
    required super.artistTags,
    required super.generalTags,
    required super.metaTags,
    required super.width,
    required super.height,
    required super.format,
    required super.md5,
    required super.lastCommentAt,
    required super.source,
    required super.createdAt,
    required super.score,
    required super.upScore,
    required super.downScore,
    required super.favCount,
    required super.uploaderId,
    required super.approverId,
    required super.rating,
    required super.fileSize,
    required super.hasChildren,
    required super.parentId,
    required super.hasLarge,
    required super.duration,
    required super.variants,
    required super.pixelHash,
    required this.uploader,
    required this.mediaAssetCount,
    required this.postedCount,
    required this.mediaAssetId,
    required this.uploadId,
    required this.uploadMediaAssetId,
    required this.pageUrl,
    required this.sourceRaw,
    required super.metadata,
    required super.status,
  });

  final DanbooruUser? uploader;
  final int mediaAssetCount;
  final int postedCount;
  final int mediaAssetId;
  final int uploadId;
  final int uploadMediaAssetId;
  final String pageUrl;
  final String sourceRaw;

  int get unPostedCount => mediaAssetCount - postedCount;
}
