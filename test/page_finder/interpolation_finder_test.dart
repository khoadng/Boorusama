// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/posts/position/src/types/interpolation_finder.dart';
import 'package:boorusama/core/posts/position/types.dart';
import 'common_test_cases.dart';
import 'mock_repository.dart';

class MockPageFinderRepositoryWithGap implements PageFinderRepository {
  final List<PageFinderQuery> requestLog = [];

  @override
  Future<PageFinderResult> fetchItems(PageFinderQuery query) async {
    requestLog.add(query);

    // Page 1: [10000, 9999, ..., 9826] (175 items)
    // Page 2: [9825, 9824, ..., 9651] (175 items)
    // Gap: 9650-9641 (10 items missing - simulating deleted posts)
    // Page 3: [9640, 9639, ..., 9466] (175 items)

    if (query.page == 1) {
      return PageFinderSuccess(
        items: List.generate(
          175,
          (i) => PageFinderTarget(id: 10000 - i),
        ),
      );
    } else if (query.page == 2) {
      return PageFinderSuccess(
        items: List.generate(
          175,
          (i) => PageFinderTarget(id: 9825 - i),
        ),
      );
    } else if (query.page == 3) {
      return PageFinderSuccess(
        items: List.generate(
          175,
          (i) => PageFinderTarget(id: 9640 - i),
        ),
      );
    }

    return PageFinderSuccess(items: const []);
  }
}

InterpolationPageFinder _createFinder(
  MockPageFinderRepository repo, {
  int searchChunkSize = 20,
  int userChunkSize = 20,
}) => InterpolationPageFinder(
  repository: repo,
  searchChunkSize: searchChunkSize,
  userChunkSize: userChunkSize,
);

void main() {
  // Run common tests
  PageFinderCommonTests.runAllTests(
    finderName: 'InterpolationPageFinder',
    createFinder:
        ({
          required repo,
          searchChunkSize = 20,
          userChunkSize = 20,
        }) => _createFinder(
          repo,
          searchChunkSize: searchChunkSize,
          userChunkSize: userChunkSize,
        ),
  );

  // Interpolation-specific tests
  group('InterpolationPageFinder - Specific Features', () {
    group('historical page optimization', () {
      test('uses historical page as starting point', () async {
        final repo = MockPageFinderRepository(
          totalItems: 1000,
          itemsPerPage: 20,
        );
        final finder = _createFinder(repo);

        final result = await finder.findPage(
          PaginationSnapshot(
            targetId: 800,
            tags: '',
            historicalPage: 10,
            historicalChunkSize: 20,
          ),
        );

        expect(result, const PageLocation(page: 11, index: 0));
        expect(repo.requestLog.first.page, 10);
      });

      test('adjusts historical page when chunk size changed', () async {
        final repo = MockPageFinderRepository(
          totalItems: 1000,
          itemsPerPage: 40,
        );
        final finder = _createFinder(
          repo,
          searchChunkSize: 40,
          userChunkSize: 40,
        );

        final result = await finder.findPage(
          PaginationSnapshot(
            targetId: 800,
            tags: '',
            historicalPage: 10,
            historicalChunkSize: 20,
          ),
        );

        expect(result, const PageLocation(page: 6, index: 0));
        expect(repo.requestLog.first.page, 20);
      });
    });

    group('interpolation efficiency', () {
      test('makes minimal requests for large datasets', () async {
        final repo = MockPageFinderRepository(
          totalItems: 100000,
          itemsPerPage: 20,
        );
        final finder = _createFinder(repo);

        final result = await finder.findPage(
          PaginationSnapshot(targetId: 50000, tags: ''),
        );

        expect(result, const PageLocation(page: 2501, index: 0));
        expect(repo.requestLog.length, lessThan(10));
      });
    });

    group('interpolation search behavior', () {
      test('efficiently narrows down search space', () async {
        final repo = MockPageFinderRepository(
          totalItems: 10000,
          itemsPerPage: 20,
        );
        final finder = _createFinder(repo);

        final result = await finder.findPage(
          PaginationSnapshot(targetId: 5000, tags: ''),
        );

        expect(result, const PageLocation(page: 251, index: 0));
        expect(repo.requestLog.length, lessThan(15));
      });

      test('makes minimal requests for nearby targets', () async {
        final repo = MockPageFinderRepository(
          totalItems: 1000,
          itemsPerPage: 20,
        );
        final finder = _createFinder(repo);

        await finder.findPage(
          PaginationSnapshot(targetId: 990, tags: ''),
        );

        expect(repo.requestLog.length, lessThanOrEqualTo(2));
      });

      test('handles target between pages without infinite loop', () async {
        final repo = MockPageFinderRepositoryWithGap();
        final finder = InterpolationPageFinder(
          repository: repo,
          searchChunkSize: 175,
          userChunkSize: 175,
        );

        // Page 2: [9825 - 9651] (175 items)
        // Gap: 9650-9641 (10 items missing)
        // Page 3: [9640 - 9466] (175 items)
        // Target 9645 is in the gap, creating infinite loop scenario
        final result = await finder.findPage(
          PaginationSnapshot(targetId: 9645, tags: ''),
        );

        expect(result, isNull);
        // Should fail gracefully without infinite loop
        expect(repo.requestLog.length, lessThan(100));
      });
    });
  });
}
