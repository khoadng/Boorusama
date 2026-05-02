import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'nozomi_memory_cache.dart';
import 'types/types.dart';

const _kNozomiIndexUrl = 'https://n.nozomi.la/index.nozomi';
const _kNozomiPopularIndexUrl =
    'https://j.gold-usergeneratedcontent.net/index-Popular.nozomi';
const _kNozomiContentUrl = 'https://j.gold-usergeneratedcontent.net';

class NozomiPostIndex {
  NozomiPostIndex({
    required Dio dio,
    NozomiMemoryCache<List<int>>? indexCache,
  }) : _dio = dio,
       _indexCache =
           indexCache ??
           NozomiMemoryCache<List<int>>(
             maxEntries: 32,
             maxTotalCost: 5000000,
           );

  final Dio _dio;
  final NozomiMemoryCache<List<int>> _indexCache;

  Future<List<int>> getPostIds({
    List<String> tags = const [],
    int page = 1,
    required int limit,
    NozomiPostOrder order = NozomiPostOrder.date,
  }) async {
    final result = await getPostIdsResult(
      tags: tags,
      page: page,
      limit: limit,
      order: order,
    );

    return result.ids;
  }

  Future<({List<int> ids, int? total})> getPostIdsResult({
    List<String> tags = const [],
    int page = 1,
    required int limit,
    NozomiPostOrder order = NozomiPostOrder.date,
  }) async {
    final pageNumber = math.max(page, 1);
    final parsedTags = _parseSearchTags(tags);
    final indexUrl = _indexUrl(order);

    if (parsedTags.positive.isEmpty && parsedTags.negative.isEmpty) {
      return _fetchIdsPageResult(
        indexUrl,
        page: pageNumber,
        limit: limit,
      );
    }

    if (parsedTags.positive.length == 1 && parsedTags.negative.isEmpty) {
      return _fetchIdsPageResult(
        _tagNozomiUrl(parsedTags.positive.single, order),
        page: pageNumber,
        limit: limit,
      );
    }

    final negativeIds = parsedTags.negative.isEmpty
        ? <int>{}
        : (await Future.wait(
            parsedTags.negative.map(
              (tag) => _fetchAllIds(_tagNozomiUrl(tag, order)),
            ),
          )).expand((ids) => ids).toSet();

    if (parsedTags.positive.isEmpty) {
      return _fetchIndexExcluding(
        negativeIds,
        page: pageNumber,
        limit: limit,
        order: order,
      );
    }

    final positiveIdLists = await Future.wait(
      parsedTags.positive.map((tag) => _fetchAllIds(_tagNozomiUrl(tag, order))),
    );
    final result = _intersectPreservingFirstOrder(positiveIdLists)
      ..removeWhere(negativeIds.contains);

    return (
      ids: _slicePage(result, page: pageNumber, limit: limit),
      total: result.length,
    );
  }

  Future<({List<int> ids, int? total})> _fetchIndexExcluding(
    Set<int> excluded, {
    required int page,
    required int limit,
    required NozomiPostOrder order,
  }) async {
    final matched = <int>[];
    var chunkPage = page;
    int? total;

    while (matched.length < limit) {
      final result = await _fetchIdsPageResult(
        _indexUrl(order),
        page: chunkPage,
        limit: limit,
      );
      final ids = result.ids;
      total ??= result.total == null
          ? null
          : math.max(result.total! - excluded.length, 0);

      if (ids.isEmpty) break;

      matched.addAll(ids.where((id) => !excluded.contains(id)));
      chunkPage += 1;
    }

    return (ids: matched.take(limit).toList(), total: total);
  }

  Future<List<int>> _fetchAllIds(String url) {
    return _indexCache.getOrLoad(
      url,
      () async {
        final response = await _dio.get<List<int>>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if ((response.statusCode ?? 0) >= 400) return const [];

        return _decodeNozomiBytes(response.data ?? const []);
      },
      estimateCost: (ids) => ids.length,
    );
  }

  Future<({List<int> ids, int? total})> _fetchIdsPageResult(
    String url, {
    required int page,
    required int limit,
  }) async {
    final cached = _indexCache.get(url);
    if (cached != null) {
      final ids = await cached;

      return (
        ids: _slicePage(ids, page: page, limit: limit),
        total: ids.length,
      );
    }

    final offset = (page - 1) * limit * 4;
    final end = offset + (limit * 4) - 1;
    final response = await _dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Range': 'bytes=$offset-$end',
        },
        validateStatus: (status) =>
            status != null &&
            (status == 200 || status == 206 || status == 404 || status == 416),
      ),
    );

    if (response.statusCode == 404 || response.statusCode == 416) {
      return (ids: const <int>[], total: 0);
    }

    final ids = _decodeNozomiBytes(response.data ?? const []);
    final total = _extractTotalIds(response, fallbackIds: ids.length);

    if (response.statusCode == 200) {
      _indexCache.set(
        url,
        ids,
        estimateCost: (ids) => ids.length,
      );

      return (
        ids: _slicePage(ids, page: page, limit: limit),
        total: total,
      );
    }

    return (ids: ids.take(limit).toList(), total: total);
  }
}

int? _extractTotalIds(
  Response response, {
  required int fallbackIds,
}) {
  final contentRange = response.headers.value('content-range');
  final totalBytes = _parseContentRangeTotalBytes(contentRange);

  if (totalBytes != null) return totalBytes ~/ 4;
  if (response.statusCode == 200) return fallbackIds;

  return null;
}

int? _parseContentRangeTotalBytes(String? value) {
  if (value == null) return null;

  final match = RegExp(r'/(\d+)$').firstMatch(value);
  if (match == null) return null;

  return int.tryParse(match.group(1)!);
}

({List<String> positive, List<String> negative}) _parseSearchTags(
  List<String> tags,
) {
  final positive = <String>[];
  final negative = <String>[];

  for (final tag in tags) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) continue;

    if (trimmed.startsWith('-') && trimmed.length > 1) {
      negative.add(_sanitizeTag(trimmed.substring(1)));
    } else {
      positive.add(_sanitizeTag(trimmed));
    }
  }

  positive.removeWhere((tag) => tag.isEmpty);
  negative.removeWhere((tag) => tag.isEmpty);

  return (positive: positive, negative: negative);
}

String _sanitizeTag(String tag) {
  return tag
      .toLowerCase()
      .trim()
      .replaceAll(' ', '_')
      .replaceAll(RegExp(r'[/#%]'), '');
}

String _indexUrl(NozomiPostOrder order) => switch (order) {
  NozomiPostOrder.date => _kNozomiIndexUrl,
  NozomiPostOrder.popular => _kNozomiPopularIndexUrl,
};

String _tagNozomiUrl(String tag, NozomiPostOrder order) {
  final encodedTag = Uri.encodeComponent(tag);

  return switch (order) {
    NozomiPostOrder.date => '$_kNozomiContentUrl/nozomi/$encodedTag.nozomi',
    NozomiPostOrder.popular =>
      '$_kNozomiContentUrl/nozomi/popular/$encodedTag-Popular.nozomi',
  };
}

List<int> _decodeNozomiBytes(List<int> bytes) {
  final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  final ids = <int>[];
  final view = ByteData.sublistView(data);

  for (var i = 0; i + 3 < data.length; i += 4) {
    ids.add(view.getUint32(i));
  }

  return ids;
}

List<int> _intersectPreservingFirstOrder(List<List<int>> lists) {
  if (lists.isEmpty) return const [];

  final result = LinkedHashSet<int>.from(lists.first);

  for (final ids in lists.skip(1)) {
    final idsSet = ids.toSet();
    result.removeWhere((id) => !idsSet.contains(id));
  }

  return result.toList();
}

List<int> _slicePage(
  List<int> ids, {
  required int page,
  required int limit,
}) {
  final offset = (page - 1) * limit;
  if (offset >= ids.length) return const [];

  return ids.skip(offset).take(limit).toList();
}
