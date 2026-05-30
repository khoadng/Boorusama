// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

mixin DanbooruClientMediaAssets {
  Dio get dio;

  Future<List<MediaAssetDto>> getMediaAssetsByIds(Set<int> ids) async {
    if (ids.isEmpty) return const [];

    final response = await dio.get(
      '/media_assets.json',
      queryParameters: {
        'search[id]': ids.join(','),
        'limit': ids.length,
      },
    );

    return (response.data as List)
        .map((item) => MediaAssetDto.fromJson(item))
        .toList();
  }
}
