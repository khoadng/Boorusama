// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../../../core/posts/rating/types.dart';
import '../../../../../../core/posts/sources/types.dart';
import '../../../../users/user/types.dart';
import '../../../post/types.dart';
import 'danbooru_upload_post.dart';

class DanbooruUpload extends Equatable {
  const DanbooruUpload({
    required this.id,
    required this.source,
    required this.uploaderId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.refererUrl,
    required this.error,
    required this.mediaAssetCount,
    required this.uploadMediaAssets,
    required this.mediaAssets,
    required this.postedCount,
    required this.uploader,
  });
  final int id;
  final String source;
  final int uploaderId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String refererUrl;
  final String error;
  final int mediaAssetCount;
  final List<UploadMediaAssetsDto> uploadMediaAssets;
  final List<MediaAssetDto> mediaAssets;
  final int postedCount;
  final DanbooruUser? uploader;

  @override
  List<Object?> get props => [
    id,
    source,
    uploaderId,
    status,
    createdAt,
    updatedAt,
    refererUrl,
    error,
    mediaAssetCount,
  ];
}

extension DanbooruUploadX on DanbooruUpload {
  DanbooruUploadPost? get previewPost => _postFromFirstMediaAsset();

  DanbooruUploadPost? _postFromFirstMediaAsset() {
    final uploadMediaAssets = this.uploadMediaAssets.firstOrNull;
    if (uploadMediaAssets == null) return null;

    final mediaAsset = mediaAssets.firstOrNull;

    if (mediaAsset == null) return null;

    return DanbooruUploadPost(
      id: uploadMediaAssets.id ?? 0,
      thumbnailImageUrl:
          mediaAsset.variants
              ?.firstWhereOrNull((e) => e.type == '360x360')
              ?.url
              .toString() ??
          '',
      sampleImageUrl:
          mediaAsset.variants
              ?.firstWhereOrNull((e) => e.type == '720x720')
              ?.url
              .toString() ??
          '',
      originalImageUrl:
          mediaAsset.variants
              ?.firstWhereOrNull((e) => e.type == 'original')
              ?.url
              .toString() ??
          '',
      width: mediaAsset.imageWidth?.toDouble() ?? 1,
      height: mediaAsset.imageHeight?.toDouble() ?? 1,
      format: mediaAsset.fileExt ?? '',
      md5: mediaAsset.md5 ?? '',
      source: PostSource.from(uploadMediaAssets.sourceUrl),
      sourceRaw: uploadMediaAssets.sourceUrl ?? '',
      pageUrl: uploadMediaAssets.pageUrl ?? '',
      createdAt: createdAt,
      score: 0,
      upScore: 0,
      downScore: 0,
      favCount: 0,
      uploaderId: uploaderId,
      rating: Rating.unknown,
      fileSize: mediaAsset.fileSize ?? 0,
      status: null,
      hasChildren: false,
      parentId: null,
      hasLarge: false,
      duration: mediaAsset.duration ?? 0,
      variants: PostVariants.fromMap({
        for (final variant in mediaAsset.variants ?? <VariantDto>[])
          variant.type: variant.url,
      }),
      tags: const {},
      generalTags: const {},
      characterTags: const {},
      artistTags: const {},
      metaTags: const {},
      copyrightTags: const {},
      lastCommentAt: null,
      approverId: null,
      uploader: uploader,
      mediaAssetCount: mediaAssetCount,
      postedCount: postedCount,
      mediaAssetId: mediaAsset.id ?? 0,
      uploadId: id,
      uploadMediaAssetId: uploadMediaAssets.id ?? 0,
      pixelHash: mediaAsset.pixelHash ?? '',
      metadata: null,
    );
  }
}
