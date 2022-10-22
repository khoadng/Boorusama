// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/common/bloc/infinite_load_mixin.dart';

class _Dummy with InfiniteLoadMixin {
  _Dummy({
    List? data,
    int? page,
    bool? hasMore,
  }) {
    if (data != null) this.data = data;
    if (page != null) this.page = page;
    if (hasMore != null) this.hasMore = hasMore;
  }
}

void main() {
  group('[refresh]', () {
    test('refresh 2 items', () async {
      final dummy = _Dummy();

      await dummy.refresh(refresh: (page) async => [1, 2]);

      expect(listEquals(dummy.data, [1, 2]), isTrue);
    });

    test('refresh will clear old data', () async {
      final dummy = _Dummy(data: [1, 2]);

      await dummy.refresh(refresh: (page) async => [3, 4]);

      expect(listEquals(dummy.data, [3, 4]), isTrue);
    });

    test('refresh will set page to 1', () async {
      final dummy = _Dummy(data: [1, 2], page: 2);

      await dummy.refresh(refresh: (page) async => [3, 4]);

      expect(dummy.page, 1);
    });
  });

  group('[misc]', () {
    test('refresh 2 items then fetch 3 items', () async {
      final dummy = _Dummy();

      await dummy.refresh(refresh: (page) async => [1, 2]);
      await dummy.fetch(fetch: (page) async => [3, 4]);

      expect(listEquals(dummy.data, [1, 2, 3, 4]), isTrue);
    });
  });

  group('[callback]', () {
    test('refresh onData triggered', () async {
      final dummy = _Dummy();
      var actual = [];

      await dummy.refresh(
        refresh: (page) async => [1, 2],
        onData: (d) => actual = d,
      );

      expect(listEquals(actual, [1, 2]), isTrue);
    });

    test('refresh onRefresh callbacks triggered', () async {
      final dummy = _Dummy();
      final completer = Completer<void>();
      final completer2 = Completer<void>();

      await dummy.refresh(
        refresh: (page) async => [1, 2],
        onRefreshStart: completer.complete,
        onRefreshEnd: completer2.complete,
      );

      expect(completer.isCompleted, isTrue);
      expect(completer2.isCompleted, isTrue);
    });
  });

  group('[fetch]', () {
    test('fetch next page, if result is empty, disable fetching', () async {
      final dummy = _Dummy(data: [1, 2], page: 1);

      await dummy.fetch(fetch: (page) async => []);

      expect(dummy.hasMore, false);
    });

    test('fetch next page, page should increase by 1', () async {
      final dummy = _Dummy(data: [1, 2], page: 1);

      await dummy.fetch(fetch: (page) async => [3, 4]);

      expect(dummy.page, 2);
    });

    test('do nothing when there is no more data', () async {
      final dummy = _Dummy(data: [1, 2], page: 1, hasMore: false);

      await dummy.fetch(fetch: (page) async => [3, 4]);

      expect(dummy.page, 1);
      expect(dummy.data, [1, 2]);
    });
  });
}
