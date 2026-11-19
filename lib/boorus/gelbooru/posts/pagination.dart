// Dart imports:
import 'dart:math' as math;

class GelbooruIdPagination {
  const GelbooruIdPagination._({
    required this.terms,
    required this.ascending,
    required this.lowerBound,
    required this.upperBound,
  });

  static final _idFilter = RegExp(r'^id:(<=|>=|<|>|=)?(\d+)$');

  static GelbooruIdPagination? fromTags(List<String> tags) {
    final terms = <String>[];
    var ascending = false;
    var sortCount = 0;
    var lower = 1;
    int? upper;

    for (final tag in tags.expand((tags) => tags.split(' '))) {
      if (tag.isEmpty) continue;
      if (tag.startsWith('sort:')) {
        sortCount++;
        if (sortCount > 1) return null;
        switch (tag) {
          case 'sort:id:asc':
            ascending = true;
          case 'sort:id' || 'sort:id:desc':
            break;
          default:
            return null;
        }
      }

      if (tag.startsWith('-id:')) return null;
      if (!tag.startsWith('id:')) {
        terms.add(tag);
        continue;
      }

      final match = _idFilter.firstMatch(tag);
      if (match == null) return null;
      final id = int.tryParse(match[2]!);
      if (id == null) return null;

      switch (match[1]) {
        case '>':
          lower = math.max(lower, id + 1);
        case '>=':
          lower = math.max(lower, id);
        case '<':
          upper = math.min(upper ?? id - 1, id - 1);
        case '<=':
          upper = math.min(upper ?? id, id);
        default:
          lower = math.max(lower, id);
          upper = math.min(upper ?? id, id);
      }
    }

    return GelbooruIdPagination._(
      terms: terms,
      ascending: ascending,
      lowerBound: lower,
      upperBound: upper,
    );
  }

  final List<String> terms;
  final bool ascending;
  final int lowerBound;
  final int? upperBound;

  List<String>? tagsAfter(int lastId) =>
      ascending ? tagsWithin(from: lastId + 1) : tagsWithin(to: lastId - 1);

  List<String>? tagsWithin({int? from, int? to}) {
    final lower = math.max(lowerBound, from ?? 1);
    final upper = switch ((upperBound, to)) {
      (final bound?, final to?) => math.min(bound, to),
      (final bound, final to) => bound ?? to,
    };
    if (upper != null && lower > upper) return null;

    return [
      ...terms,
      if (lower > 1) 'id:>${lower - 1}',
      if (upper != null) 'id:<${upper + 1}',
    ];
  }
}

const kGelbooruMaxOffset = 1000;
const _maxSequentialHops = 2;
const _maxPostId = 0x7fffffff;

typedef GelbooruDeepPage = ({List<String> tags, int page, int skipped});
typedef GelbooruCountProbe = ({int count, int? firstId});

final class GelbooruPageCursors {
  final _cursors = <String, Map<int, int>>{};

  Future<GelbooruDeepPage?> locate({
    required List<String> tags,
    required GelbooruIdPagination pagination,
    required int page,
    required int limit,
    required Future<int?> Function(List<String> tags, int page) lastIdOf,
    required Future<GelbooruCountProbe> Function(List<String> tags) probe,
  }) async {
    final pagesPerHop = kGelbooruMaxOffset ~/ limit + 1;
    final hop = (page - 1) ~/ pagesPerHop;
    final key = _key(tags, limit);
    if (page == 1) _cursors.remove(key);
    final cursors = _cursors.putIfAbsent(key, () => {});

    final cursor = switch (hop) {
      0 => null,
      _ =>
        cursors[hop] ??
            await _findCursor(
              cursors: cursors,
              hop: hop,
              span: pagesPerHop * limit,
              tags: tags,
              pagination: pagination,
              lastIdOf: (tags) => lastIdOf(tags, pagesPerHop),
              probe: probe,
            ),
    };
    if (hop > 0) {
      if (cursor == null) return null;
      cursors[hop] = cursor;
    }

    final pageTags = switch (cursor) {
      final cursor? => pagination.tagsAfter(cursor),
      null => tags,
    };
    if (pageTags == null) return null;

    return (
      tags: pageTags,
      page: (page - 1) % pagesPerHop + 1,
      skipped: hop * pagesPerHop * limit,
    );
  }

  Future<int?> _findCursor({
    required Map<int, int> cursors,
    required int hop,
    required int span,
    required List<String> tags,
    required GelbooruIdPagination pagination,
    required Future<int?> Function(List<String> tags) lastIdOf,
    required Future<GelbooruCountProbe> Function(List<String> tags) probe,
  }) async {
    final nearest = cursors.keys
        .where((index) => index < hop)
        .fold(0, math.max);
    if (hop - nearest > _maxSequentialHops) {
      return _searchCursor(
        offset: hop * span,
        pagination: pagination,
        probe: probe,
      );
    }

    var cursor = cursors[nearest];
    for (var index = nearest + 1; index <= hop; index++) {
      final hopTags = switch (cursor) {
        final cursor? => pagination.tagsAfter(cursor),
        null => tags,
      };
      if (hopTags == null) return null;
      cursor = await lastIdOf(hopTags);
      if (cursor == null) return null;
      cursors[index] = cursor;
    }

    return cursor;
  }

  Future<int?> _searchCursor({
    required int offset,
    required GelbooruIdPagination pagination,
    required Future<GelbooruCountProbe> Function(List<String> tags) probe,
  }) async {
    Future<int> count({int? from, int? to}) async =>
        switch (pagination.tagsWithin(from: from, to: to)) {
          final tags? => (await probe(tags)).count,
          null => 0,
        };

    final first = switch (pagination.tagsWithin()) {
      final tags? => await probe(tags),
      null => (count: 0, firstId: null),
    };
    if (first.count < offset) return null;

    if (pagination.ascending) {
      var low = pagination.lowerBound;
      var high = pagination.upperBound ?? _maxPostId;
      while (low < high) {
        final mid = low + (high - low) ~/ 2;
        if (await count(to: mid) >= offset) {
          high = mid;
        } else {
          low = mid + 1;
        }
      }
      return low;
    }

    var low = pagination.lowerBound;
    var high = first.firstId ?? pagination.upperBound ?? _maxPostId;
    var countFromLow = first.count;
    var countAboveHigh = 0;
    var bisect = false;
    while (low < high) {
      final mid = bisect
          ? low + (high - low + 1) ~/ 2
          : (low +
                    (countFromLow - offset) *
                        (high + 1 - low) ~/
                        (countFromLow - countAboveHigh))
                .clamp(low + 1, high);
      bisect = !bisect;
      final midCount = await count(from: mid);
      if (midCount >= offset) {
        low = mid;
        countFromLow = midCount;
      } else {
        high = mid - 1;
        countAboveHigh = midCount;
      }
    }

    return low;
  }

  void record({
    required List<String> tags,
    required int page,
    required int limit,
    required int? lastId,
  }) {
    final pagesPerHop = kGelbooruMaxOffset ~/ limit + 1;
    if (lastId == null || page % pagesPerHop != 0) return;

    _cursors.putIfAbsent(_key(tags, limit), () => {})[page ~/ pagesPerHop] =
        lastId;
  }

  String _key(List<String> tags, int limit) => '${tags.join(' ')}|$limit';
}
