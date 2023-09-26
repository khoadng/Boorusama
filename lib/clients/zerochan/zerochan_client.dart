// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kZerochanUrl = 'https://www.zerochan.net';

class ZerochanClient {
  ZerochanClient({
    Dio? dio,
    this.logger,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _kZerochanUrl,
              headers: {
                'User-Agent': 'My test client - anon',
              },
            ));

  final Dio _dio;
  final void Function(String message)? logger;

  /// Input tag must be in snake case
  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page,
    int? limit,
  }) async {
    final tagString = tags
            ?.map((e) => e.replaceAll('_', ' '))
            .map((e) => e.replaceAll(' ', '+'))
            .join(',') ??
        '';

    final response = await _dio.get('/$tagString?json',
        queryParameters: {
          if (page != null) 'p': page,
          if (limit != null) 'l': limit,
        },
        options: Options(
          responseType: ResponseType.plain,
        ));

    // return empty if response is HTML
    if (response.data.toString().startsWith('<!DOCTYPE html>')) {
      logger?.call('Response is HTML, returning empty list. Input tags: $tags');
      return [];
    }

    final json = jsonDecode(response.data);

    final data = json['items'];

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
