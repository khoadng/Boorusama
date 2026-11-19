import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:boorusama/core/http/client/types.dart';

class GelbooruPaginationBackend implements HttpClientAdapter {
  GelbooruPaginationBackend({
    this.postCount = 2505,
    this.depthLimit = 1000,
    this.unavailableIds = const {},
    this.blacklistedIds = const {},
    this.failOnRequest,
    this.ignoreIdFilters = false,
  });

  final int postCount;
  final int depthLimit;
  final Set<int> unavailableIds;
  final Set<int> blacklistedIds;
  int? failOnRequest;
  final bool ignoreIdFilters;
  final requests = <Map<String, dynamic>>[];
  var tooDeepResponses = 0;

  late final dio = Dio(BaseOptions(baseUrl: 'https://gelbooru.example'))
    ..httpClientAdapter = this
    ..interceptors.add(
      const PaginationLimitErrorInterceptor(
        detectionString: 'Too deep! Pull it back some',
        detectionStatusCode: 200,
        returnedStatusCode: 410,
      ),
    );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final params = Map<String, dynamic>.from(options.queryParameters);
    requests.add(params);
    if (requests.length == failOnRequest) {
      return ResponseBody.fromString('Temporary failure', 503);
    }

    final limit = params['limit'] as int? ?? 100;
    final offset = (params['pid'] as int? ?? 0) * limit;
    if (offset > depthLimit) {
      tooDeepResponses++;
      return ResponseBody.fromString('Too deep! Pull it back some.', 200);
    }

    final tags = (params['tags'] as String? ?? '').split(' ');
    final ascending = tags.contains('sort:id:asc');
    var ids = List.generate(postCount, (index) => index + 1);
    if (!ignoreIdFilters) {
      for (final tag in tags) {
        final match = RegExp(r'^id:(<=|>=|<|>|=)?(\d+)$').firstMatch(tag);
        if (match == null) continue;
        final bound = int.parse(match[2]!);
        ids = ids
            .where(
              (id) => switch (match[1]) {
                '<' => id < bound,
                '<=' => id <= bound,
                '>' => id > bound,
                '>=' => id >= bound,
                _ => id == bound,
              },
            )
            .toList();
      }
    }
    if (!ascending) ids = ids.reversed.toList();
    final page = ids.skip(offset).take(limit);

    return ResponseBody.fromString(
      jsonEncode({
        '@attributes': {'count': ids.length, 'offset': offset, 'limit': limit},
        'post': [
          for (final id in page)
            {
              'id': id,
              if (!unavailableIds.contains(id)) 'md5': 'hash-$id',
              'file_url': 'https://gelbooru.example/$id.jpg',
              'tags':
                  'test_tags ${blacklistedIds.contains(id) ? 'blocked' : ''}',
              'rating': 'general',
            },
        ],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
