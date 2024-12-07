// Package imports:

// Project imports:
import 'package:boorusama/boorus/danbooru/uploads/danbooru_upload.dart';
import 'package:boorusama/boorus/danbooru/users/user/user.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/danbooru_client_uploads.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';

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
