// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/danbooru_client_uploads.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'package:boorusama/core/feats/posts/posts.dart';

class DanbooruUpload extends Equatable {
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
  final User? uploader;

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

class DanbooruUploadRepository {
  const DanbooruUploadRepository({
    required this.client,
  });

  final DanbooruClient client;

  Future<List<DanbooruUpload>> getUploads({
    required int userId,
    int? page,
    int? limit,
    bool? isPosted,
    UploadOrder? order,
    UploadStatus? status,
    List<String>? tags,
  }) async {
    final dtos = await client.getUploads(
      userId: userId,
      page: page,
      limit: limit,
      isPosted: isPosted,
      order: order,
      status: status,
      tags: tags,
    );

    return dtos.map(
      (e) {
        return DanbooruUpload(
          id: e.id ?? 0,
          source: e.source ?? '',
          uploaderId: e.uploaderId ?? 0,
          status: e.status ?? '',
          createdAt: e.createdAt ?? DateTime(1),
          updatedAt: e.updatedAt ?? DateTime(1),
          refererUrl: e.refererUrl ?? '',
          error: e.error ?? '',
          mediaAssetCount: e.mediaAssetCount ?? 0,
          postedCount: e.posts?.length ?? 0,
          uploadMediaAssets: e.uploadMediaAssets ?? <UploadMediaAssetsDto>[],
          uploader: e.uploader != null ? userDtoToUser(e.uploader!) : null,
          mediaAssets: e.mediaAssets ?? <MediaAssetDto>[],
        );
      },
    ).toList();
  }
}

class DanbooruUploadPost extends DanbooruPost {
  DanbooruUploadPost({
    required super.id,
    required super.thumbnailImageUrl,
    required super.sampleImageUrl,
    required super.originalImageUrl,
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
    required super.isBanned,
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
    required this.uploadMediaAssetId,
    required this.pageUrl,
    required this.sourceRaw,
  });

  final User? uploader;
  final int mediaAssetCount;
  final int postedCount;
  final int mediaAssetId;
  final int uploadMediaAssetId;
  final String pageUrl;
  final String sourceRaw;

  int get unPostedCount => mediaAssetCount - postedCount;
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
      thumbnailImageUrl: mediaAsset.variants
              ?.firstWhereOrNull((e) => e.type == '360x360')
              ?.url
              .toString() ??
          '',
      sampleImageUrl: mediaAsset.variants
              ?.firstWhereOrNull((e) => e.type == '720x720')
              ?.url
              .toString() ??
          '',
      originalImageUrl: mediaAsset.variants
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
      fileSize: mediaAsset.fileSize?.toInt() ?? 0,
      isBanned: false,
      hasChildren: false,
      parentId: null,
      hasLarge: false,
      duration: mediaAsset.duration ?? 0,
      variants: mediaAsset.variants?.map(variantDtoToVariant).toList() ?? [],
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
      uploadMediaAssetId: uploadMediaAssets.id ?? 0,
      pixelHash: mediaAsset.pixelHash ?? '',
    );
  }
}
