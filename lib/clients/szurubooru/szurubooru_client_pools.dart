// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

mixin SzurubooruClientPools {
  Dio get dio;

  Future<List<PoolDto>> getPools({
    int? offset,
    int limit = 50,
    String? query,
  }) async {
    final response = await dio.get(
      '/api/pools',
      queryParameters: {
        if (offset != null) 'offset': offset,
        'limit': limit,
        if (query != null) 'query': query,
      },
    );

    final results = response.data['results'] as List;

    return results
        .map((e) => PoolDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
