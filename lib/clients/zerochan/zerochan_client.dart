import 'package:dio/dio.dart';

import 'types/types.dart';

const _kZerochanUrl = 'https://www.zerochan.net';

class ZerochanClient {
  ZerochanClient({
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _kZerochanUrl,
              headers: {
                'User-Agent': 'My test client - anon',
              },
            ));

  final Dio _dio;

  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page,
    int? limit,
  }) async {
    final tagString = tags?.map((e) => e.replaceAll(' ', '+')).join(',') ?? '';

    final response = await _dio.get(
      '/$tagString?json',
      queryParameters: {
        if (page != null) 'p': page,
        if (limit != null) 'l': limit,
      },
    );

    final data = response.data['items'];

    return (data as List).map((e) => PostDto.fromJson(e)).toList();
  }

  Future<List<AutocompleteDto>> getAutocomplete({
    required String query,
  }) async {
    final response = await _dio.get(
      '/suggest?json',
      queryParameters: {
        'q': query,
      },
    );

    final data = response.data['suggestions'];

    return (data as List).map((e) => AutocompleteDto.fromJson(e)).toList();
  }
}
