// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
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
  final List<UploadMediaAssetsDto> mediaAssets;
  final List<DanbooruPost> posts;

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
    required this.mediaAssets,
    required this.posts,
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
          posts: e.posts?.map((e) => postDtoToPost(e)).toList() ??
              <DanbooruPost>[],
          mediaAssets: e.uploadMediaAssets ?? <UploadMediaAssetsDto>[],
        );
      },
    ).toList();
  }
}

extension DanbooruUploadX on DanbooruUpload {
  int get postedCount => posts.length;

  DanbooruPost get previewPost =>
      posts.firstOrNull ?? _postFromFirstMediaAsset() ?? DanbooruPost.empty();

  DanbooruPost? _postFromFirstMediaAsset() {
    final mediaAssets = this.mediaAssets.firstOrNull;
    if (mediaAssets == null) return null;

    final mediaAsset = mediaAssets.mediaAsset;

    return DanbooruPost(
      id: mediaAssets.id ?? 0,
      thumbnailImageUrl: mediaAsset?.variants
              ?.firstWhereOrNull((e) => e.type == '360x360')
              ?.url
              .toString() ??
          '',
      sampleImageUrl: mediaAsset?.variants
              ?.firstWhereOrNull((e) => e.type == '720x720')
              ?.url
              .toString() ??
          '',
      originalImageUrl: mediaAsset?.variants
              ?.firstWhereOrNull((e) => e.type == 'original')
              ?.url
              .toString() ??
          '',
      width: mediaAsset?.imageWidth?.toDouble() ?? 1,
      height: mediaAsset?.imageHeight?.toDouble() ?? 1,
      format: mediaAsset?.fileExt ?? '',
      md5: mediaAsset?.md5 ?? '',
      source: PostSource.from(mediaAssets.sourceUrl),
      createdAt: createdAt,
      score: 0,
      upScore: 0,
      downScore: 0,
      favCount: 0,
      uploaderId: uploaderId,
      rating: Rating.unknown,
      fileSize: mediaAsset?.fileSize?.toInt() ?? 0,
      isBanned: false,
      hasChildren: false,
      parentId: null,
      hasLarge: false,
      duration: mediaAsset?.duration ?? 0,
      variants: mediaAsset?.variants?.map(variantDtoToVariant).toList() ?? [],
      generalTags: const [],
      characterTags: const [],
      artistTags: const [],
      metaTags: const [],
      copyrightTags: const [],
      lastCommentAt: null,
      approverId: null,
    );
  }
}
