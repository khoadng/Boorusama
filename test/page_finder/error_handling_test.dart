// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/posts/position/src/types/interpolation_finder.dart';
import 'package:boorusama/core/posts/position/types.dart';

class _ErrorThrowingRepository implements PageFinderRepository {
  _ErrorThrowingRepository(this.errorToThrow);

  final PageFinderResult errorToThrow;

  @override
  Future<PageFinderResult> fetchItems(PageFinderQuery query) async =>
      errorToThrow;
}

void main() {
  group('Error propagation', () {
    final cases = [
      (
        name: 'pagination limit',
        error: PageFinderPaginationLimitReached(
          maxPage: 5000,
          requestedPage: 5001,
        ),
        exceptionType: PageFinderBeyondLimitException,
      ),
      (
        name: 'server error',
        error: PageFinderServerError(message: 'Server error'),
        exceptionType: PageFinderServerException,
      ),
    ];

    for (final c in cases) {
      test('throws ${c.exceptionType} when ${c.name} occurs', () {
        final repo = _ErrorThrowingRepository(c.error);
        final finder = InterpolationPageFinder(
          repository: repo,
          searchChunkSize: 20,
          userChunkSize: 20,
        );

        expect(
          () => finder.findPage(
            PaginationSnapshot(targetId: 1000, tags: 'test'),
          ),
          throwsA(
            isA<dynamic>().having(
              (e) => e.runtimeType,
              'type',
              c.exceptionType,
            ),
          ),
        );
      });
    }

    test('returns null when empty page received', () async {
      final repo = _ErrorThrowingRepository(PageFinderEmptyPage());
      final finder = InterpolationPageFinder(
        repository: repo,
        searchChunkSize: 20,
        userChunkSize: 20,
      );

      final result = await finder.findPage(
        PaginationSnapshot(targetId: 1000, tags: 'test'),
      );

      expect(result, isNull);
    });

    test(
      'limits retries when encountering empty pages during interpolation',
      () async {
        final mixedRepo = _MixedResponseRepository();
        final finder = InterpolationPageFinder(
          repository: mixedRepo,
          searchChunkSize: 100,
          userChunkSize: 100,
        );

        final result = await finder.findPage(
          PaginationSnapshot(targetId: 500, tags: 'test'),
        );

        expect(result, isNull);
        // Should make: initial fetch + jump (empty) + 1 retry = 3 total
        expect(mixedRepo.requestCount, equals(3));
      },
    );
  });
}

class _MixedResponseRepository implements PageFinderRepository {
  var requestCount = 0;

  @override
  Future<PageFinderResult> fetchItems(PageFinderQuery query) async {
    requestCount++;
    // First request returns data, all subsequent return empty
    if (requestCount == 1) {
      return PageFinderSuccess(
        items: const [
          PageFinderTarget(id: 10000),
          PageFinderTarget(id: 9999),
        ],
      );
    }
    return PageFinderEmptyPage();
  }
}
