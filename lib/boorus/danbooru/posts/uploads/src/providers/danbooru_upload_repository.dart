// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../../../../users/user/types.dart';
import '../types/danbooru_upload.dart';

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
