// Dart imports:
import 'dart:isolate';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

enum UploadOrder {
  id,
  idAsc,
  random,
}

enum UploadStatus {
  pending,
  completed,
  error,
}

mixin DanbooruClientUploads {
  Dio get dio;

  Future<List<UploadDto>> getUploads({
    required int userId,
    int? page,
    int? limit,
    bool? isPosted,
    UploadOrder? order,
    UploadStatus? status,
    List<String>? tags,
  }) async {
    final response = await dio.get(
      '/users/$userId/uploads.json',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (isPosted != null) 'search[is_posted]': isPosted,
        if (order != null)
          'search[order]': switch (order) {
            UploadOrder.id => 'id',
            UploadOrder.idAsc => 'id_asc',
            UploadOrder.random => 'random',
          },
        if (status != null)
          'search[status]': switch (status) {
            UploadStatus.pending => 'pending',
            UploadStatus.completed => 'completed',
            UploadStatus.error => 'error',
          },
        if (tags != null && tags.isNotEmpty)
          'search[ai_tags_match]': tags.join(' '),
        if (isPosted != null && isPosted == true)
          'only':
              'id,source,uploader_id,status,created_at,updated_at,referer_url,error,media_asset_count,upload_media_assets,posts',
      },
    );

    return Isolate.run(() => (response.data as List)
        .map((item) => UploadDto.fromJson(item))
        .toList());
  }
}
