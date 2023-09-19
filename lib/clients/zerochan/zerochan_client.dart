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
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _kZerochanUrl,
              headers: {
                'User-Agent': 'My test client - anon',
              },
            ));

  final Dio _dio;

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

    final rawData = _removeUnwantedHtmlElementFromJson(response.data);
    final json = jsonDecode(rawData);

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

// This is a workaround for the fact that the Zerochan API returns HTML
String _removeUnwantedHtmlElementFromJson(String jsonString) {
  // Split the JSON string into lines
  final lines = jsonString.split('\n');

  var markerFound = false;

  // Initialize a result string with the first line
  final result = StringBuffer(lines.first);

  // Iterate through the lines, starting from the second line
  for (var i = 1; i < lines.length; i++) {
    final line = lines[i];

    // Check if the line contains the marker
    if (line.contains('"items": [')) markerFound = true;

    // If the marker is found, add the line to the result
    if (markerFound) result.write('$line\n');
  }

  return result.toString();
}
