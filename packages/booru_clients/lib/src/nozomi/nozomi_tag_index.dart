import 'package:dio/dio.dart';

import 'nozomi_memory_cache.dart';
import 'types/types.dart';

const _kNozomiContentUrl = 'https://j.gold-usergeneratedcontent.net';

class NozomiTagIndex {
  NozomiTagIndex({
    required Dio dio,
    NozomiMemoryCache<Map<String, int>>? bucketCache,
  }) : _dio = dio,
       _bucketCache =
           bucketCache ??
           NozomiMemoryCache<Map<String, int>>(
             maxEntries: 27,
             maxTotalCost: 0,
           );

  final Dio _dio;
  final NozomiMemoryCache<Map<String, int>> _bucketCache;

  Future<List<NozomiAutocompleteDto>> autocomplete({
    required String query,
    int limit = 25,
  }) async {
    final term = _sanitizeTag(query.replaceFirst(RegExp(r'^-'), ''));
    if (term.isEmpty) return const [];

    final bucket = await _getBucket(_bucketKey(term));
    final results = <NozomiAutocompleteDto>[];

    for (final entry in bucket.entries) {
      if (!entry.key.startsWith(term)) continue;

      results.add(
        NozomiAutocompleteDto(
          tag: entry.key,
          postCount: entry.value,
        ),
      );

      if (results.length >= limit) break;
    }

    return results;
  }

  Future<NozomiTagCountLookup> resolveCounts(Iterable<String> tags) async {
    final normalizedTags = tags.map(_sanitizeTag).where((tag) {
      return tag.isNotEmpty;
    }).toSet();

    if (normalizedTags.isEmpty) {
      return const NozomiTagCountLookup(counts: {}, missing: {});
    }

    final bucketKeys = normalizedTags.map(_bucketKey).toSet();
    final buckets = await Future.wait(
      bucketKeys.map((key) async => MapEntry(key, await _getBucket(key))),
    );
    final bucketByKey = Map<String, Map<String, int>>.fromEntries(buckets);
    final counts = <String, int>{};
    final missing = <String>{};

    for (final tag in normalizedTags) {
      final count = bucketByKey[_bucketKey(tag)]?[tag];

      if (count == null) {
        missing.add(tag);
      } else {
        counts[tag] = count;
      }
    }

    return NozomiTagCountLookup(
      counts: counts,
      missing: missing,
    );
  }

  Future<Map<String, int>> _getBucket(String key) {
    return _bucketCache.getOrLoad(
      key,
      () async {
        final response = await _dio.get(
          '$_kNozomiContentUrl/search-$key.json',
          options: Options(
            responseType: ResponseType.json,
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if ((response.statusCode ?? 0) >= 400) return const {};

        return switch (response.data) {
          final Map m => m.map(
            (key, value) => MapEntry(
              key.toString(),
              switch (value) {
                final int i => i,
                final num n => n.toInt(),
                _ => 0,
              },
            ),
          ),
          _ => const <String, int>{},
        };
      },
      estimateCost: (bucket) => bucket.length,
    );
  }
}

String _sanitizeTag(String tag) {
  return tag
      .toLowerCase()
      .trim()
      .replaceAll(' ', '_')
      .replaceAll(RegExp(r'[/#%]'), '');
}

String _bucketKey(String term) {
  if (term.isEmpty) return '0';

  final first = term[0];
  return RegExp(r'^[a-z]$').hasMatch(first) ? first : '0';
}
